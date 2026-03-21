# Mi configuración de dwm
>[!NOTE]
>Esta configuración solo es un fork del DWM de [Ferchupessoadev](https://www.github.com/Ferchupessoadev).

Cambios:

Movimiento entre escritorios con MOD/SUPER + Alt + ->/<-

Link del [DWM Original](https://github.com/Ferchupessoadev/dwm)

## Estructura del proyecto dwm/

dwm/
├── bar/               # scripts de la barra de estado
│   ├── bar.sh
│   └── scripts/
├── codules/           # código fuente (.c)
├── hodules/           # cabeceras (.h) temáticas
├── core/              # scripts de autostart y configuración
├── docs/              # documentación y capturas
├── patches/           # parches aplicados
├── config.h           # configuración principal
├── config.mk          # configuración de compilación
└── Makefile           # sistema de construcción

## Estructura de st

st/
├── codules/           # código fuente (.c)
│   ├── st.c
│   └── x.c
├── hodules/           # cabeceras (.h)
│   ├── arg.h
│   ├── st.h
│   └── win.h
├── core/              # scripts de autostart (opcional)
│   └── build.sh       # si se usa
├── docs/              # documentación
│   ├── LICENSE
│   ├── README.md
│   ├── st.1
│   ├── st.info
│   └── st.png
├── patches/           # parches
│   └── ... (todos los .diff)
├── config.h           # configuración personalizada
├── config.mk          # configuración de compilación
└── Makefile           # sistema de construcción
