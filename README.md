# 🐍 venvswitch

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Zsh](https://img.shields.io/badge/Zsh-Latest-blue)
![Oh My Zsh](https://img.shields.io/badge/Oh%20My%20Zsh-Latest-red)

> Smart Python virtual environment switching for Zsh.

---

## 📋 Tabla de contenidos

- [Características](#-características)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Contribución](#-contribución)
- [Licencia](#-licencia)

## ✨ Características

- 🔄 **Conmutación Automática**: Detecta y cambia entorno al entrar en directorios
- 📁 **Entornos Locales**: Crea venvs en carpetas de proyecto
- 🛠️ **Multi-tool**: Soporta virtualenv, pipenv, poetry, conda
- ⚡ **Optimizado**: Cache inteligente para escaneo rápido
- 🎛️ **Configurable**: Opciones extensivas via variables de entorno
- 🛡️ **Robusto**: Manejo de errores completo

## 🛠️ Instalación

```bash
# Clonar
git clone https://github.com/murapadev/venvswitch.git
cd venvswitch

# Instalar
./install.sh
```

Añade `venvswitch` a tu plugin list en `.zshrc`:
```bash
plugins=(... venvswitch)
```

## 🚀 Uso

```bash
# Comandos disponibles
venv switch     # Cambiar entorno manualmente
venv create    # Crear nuevo entorno
venv list      # Listar entornos
```

## 📝 Contribución

Las contribuciones son bienvenidas. Consulta CONTRIBUTING.md.

## 📄 Licencia

Este proyecto está licenciado bajo los términos de la licencia MIT.

---

*Hecho con ❤️ por [murapadev](https://github.com/murapadev)*