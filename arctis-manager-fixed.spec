# -*- mode: python ; coding: utf-8 -*-
from pathlib import Path
import sys
import subprocess

from PyInstaller.utils.hooks import collect_submodules, collect_data_files

sys.path.append('.')

# Improved hidden imports for PyQt6
hiddenimports = [
    'PyQt6', 
    'PyQt6.sip',
    'PyQt6.QtCore',
    'PyQt6.QtGui', 
    'PyQt6.QtWidgets',
    'PyQt6.QtDBus',
    'PyQt6.QtSvg',
    # Fix qasync issues
    'qasync',
    'asyncio',
    # USB and DBus
    'usb.core',
    'usb.util', 
    'dbus_next',
    'dbus_next.aio',
]
hiddenimports += collect_submodules('arctis_manager.devices')

# Get Qt plugins path more reliably
python_ver_p = subprocess.run(['python3', '--version'], check=True, stdout=subprocess.PIPE)
python_ver = '.'.join(python_ver_p.stdout.decode('utf-8').replace('Python ', '').split('.')[0:2])

# Try multiple possible Qt paths
possible_qt_paths = [
    f'/home/maghi/.local/share/virtualenvs/Linux-Arctis-Manager-HzSaHgZh/lib/python{python_ver}/site-packages/PyQt6/Qt6',
    f'/home/maghi/.local/share/virtualenvs/Linux-Arctis-Manager-HzSaHgZh/lib64/python{python_ver}/site-packages/PyQt6/Qt6',
    f'/usr/lib/python{python_ver}/site-packages/PyQt6/Qt6',
    f'/usr/lib64/python{python_ver}/site-packages/PyQt6/Qt6',
]

pyqt6_path = None
for path in possible_qt_paths:
    if Path(path).exists():
        pyqt6_path = Path(path)
        break

if not pyqt6_path:
    # Fallback - try to find it dynamically
    try:
        import PyQt6
        pyqt6_path = Path(PyQt6.__file__).parent / 'Qt6'
    except ImportError:
        pyqt6_path = Path('.')  # Fallback

print(f"Using Qt path: {pyqt6_path}")

# Collect Qt plugins and data files
datas = [
    ('arctis_manager/images/steelseries_logo.svg', 'arctis_manager/images/'),
    ('arctis_manager/lang/*.json', 'arctis_manager/lang/'),
]

# Add Qt plugins if they exist
if pyqt6_path.exists():
    qt_plugins = [
        ('platforms', 'PyQt6/Qt6/plugins/platforms/'),
        ('imageformats', 'PyQt6/Qt6/plugins/imageformats/'),
        ('iconengines', 'PyQt6/Qt6/plugins/iconengines/'),
        ('platformthemes', 'PyQt6/Qt6/plugins/platformthemes/'),
    ]
    
    for plugin_dir, dest_dir in qt_plugins:
        plugin_path = pyqt6_path / 'plugins' / plugin_dir
        if plugin_path.exists():
            datas.append((str(plugin_path), dest_dir))
            print(f"Added Qt plugin: {plugin_path}")

a = Analysis(
    ['arctis_manager.py'],
    pathex=['.'],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={
        'PyQt6': {
            'debug': False,
        }
    },
    runtime_hooks=[],
    excludes=[
        # Exclude unused GUI frameworks to reduce size
        'PyQt5', 'PySide2', 'PySide6', 'tkinter', 'matplotlib'
    ],
    noarchive=False,
    optimize=0,
)

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='arctis-manager-fixed',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,  # Disable UPX to avoid Qt issues
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,  # Disable console for GUI app
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='arctis_manager/images/steelseries_logo.svg' if Path('arctis_manager/images/steelseries_logo.svg').exists() else None,
)