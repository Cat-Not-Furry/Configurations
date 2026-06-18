from __future__ import annotations

from dataclasses import dataclass
from typing import Literal

from ignis.services.audio import Stream


@dataclass
class PortInfo:
    id: str
    label: str
    available: bool
    is_active: bool
    priority: int


def strip_common_prefix(descriptions: list[str]) -> dict[str, str]:
    if not descriptions:
        return {}
    if len(descriptions) == 1:
        return {descriptions[0]: descriptions[0]}

    prefix = descriptions[0]
    for desc in descriptions[1:]:
        while prefix and not desc.startswith(prefix):
            prefix = prefix[:-1]

    prefix = prefix.rstrip(" -")

    result: dict[str, str] = {}
    for desc in descriptions:
        short = desc[len(prefix) :].lstrip(" -") if prefix else desc
        result[desc] = short or desc
    return result


def get_ports(stream: Stream) -> list[PortInfo]:
    gvc = stream.stream
    if not gvc:
        return []

    active = gvc.get_port()
    active_id = active.port if active else None

    ports: list[PortInfo] = []
    for port in gvc.get_ports() or []:
        port_id = port.port or ""
        ports.append(
            PortInfo(
                id=port_id,
                label=port.human_port or port_id,
                available=bool(port.available),
                is_active=port_id == active_id if active_id else False,
                priority=int(port.priority) if port.priority else 0,
            )
        )
    return ports


def format_port_subtitle(ports: list[PortInfo]) -> str:
    if not ports:
        return ""

    active = next((p for p in ports if p.is_active), ports[0])
    label = f"Puerto: {active.label}"
    if not active.available:
        label += " · desconectado"
    return label


def device_icon(
    description: str,
    kind: Literal["speaker", "microphone"],
    stream: Stream | None = None,
) -> str:
    desc_lower = description.lower()
    if kind == "speaker":
        if "hdmi" in desc_lower or "displayport" in desc_lower:
            return "video-display-symbolic"
        if "headphone" in desc_lower or "headset" in desc_lower:
            return "audio-headphones-symbolic"
        return "audio-speakers-symbolic"

    if stream:
        return stream.icon_name
    return "microphone-sensitivity-medium-symbolic"


def stream_sort_key(stream: Stream) -> int:
    ports = get_ports(stream)
    if not ports:
        return 0

    active = next((p for p in ports if p.is_active), None)
    if active:
        return active.priority
    return max(p.priority for p in ports)


def sort_streams(streams: list[Stream]) -> list[Stream]:
    return sorted(streams, key=stream_sort_key, reverse=True)


def set_port(stream: Stream, port_id: str) -> None:
    gvc = stream.stream
    if gvc:
        gvc.change_port(port_id)


def has_any_available_port(stream: Stream) -> bool:
    ports = get_ports(stream)
    if not ports:
        return True
    return any(p.available for p in ports)


def short_label_for_stream(stream: Stream, streams: list[Stream]) -> str:
    labels = strip_common_prefix([s.description for s in streams])
    return labels.get(stream.description, stream.description)
