# BEAM App: Finite Element Analysis of Beams

## Description

BEAM App is a fortran application that can be used to analyse beams and slender structures.

Current features:

* Geometrically nonlinear beam theory (Simo and Vu-Quoc)

* Linear elastic material model

* Initally straight elements

* Quasi-static analysis

* Newton-Raphson and Arc-Length solution algorithm

## Usage

Application functions are written in modules which need to be compiled only the first time. For now the input is also a fortran file, which needs to be compiled every time it is changed. The goal is to completely separate the input from application. This will be done some time in the future.

For now, there are two possibilities:

1. Input using a script, where you specify everything. This is convinient for simple first attempts.

2. Input using a script and support files, where you specify parameters in a separate file. This is more suitable for analysis that is run multiple times with slighlty tweaked parameters.

Both examples can be seen in *Examples*.

### Compiling libraries

The first time you need to compile all the included libraries by executing compilation script.

On Windows

```batch
scripts\comp_win_gnu.bat
```

On MacOS

```zsh
chmod +x scripts/comp_mac_gnu.zsh

scripts/comp_mac_gnu.zsh
```


On Linux

```sh
chmod +x scripts/comp_lin_gnu.sh

sh scripts/comp_lin_gnu.sh
```



|       | Windows            | MacOS              | Linux             |
|-------|--------------------|--------------------|-------------------|
| GNU   | `comp_win_gnu.bat` | `comp_mac_gnu.zsh` | `comp_lin_gnu.sh` |
| Intel | `comp_win_int.bat` | `comp_mac_int.zsh` | `comp_lin_int.sh` |

### Building a program

Every time you change your main program (i.e. `examples/example.f90`), you need to rebuild. This can be done by a script from the lower table.

On Windows

```batch
scripts\build_win_gnu.bat examples\example.f90
```

or Linux

```bash
sh scripts/build_lin_gnu.sh examples/example.f90
```

|       | Windows            | MacOS              | Linux             |
|-------|--------------------|--------------------|-------------------|
| GNU   | `build_win_gnu.bat` | `build_mac_gnu.zsh` | `build_lin_gnu.sh` |
| Intel | `build_win_int.bat` | `build_mac_int.zsh` | `build_lin_int.sh` |


### Running a program

On Windows use a line

```batch
test01.exe
```

on Linux/MacOS do

```bash
./test01.exe
```

## Requirements

BEAM App provides you with source code, which needs to be compiled in order to run. In the folder `Build` you should find some scripts to automate this process written for different combinations of operating systems and compilers. If you have another set up you can probably mesh something together or direct the question to me as it might be useful to the others as well.

## Installation

### Installing on Windows

Install [GNU Fortran Compiler](https://gcc.gnu.org/wiki/GFortranBinaries) or [Intel Fortran Compiler](https://software.intel.com/content/www/us/en/develop/tools/compilers/fortran-compilers.html).

 * MinGW Installation Options: Under all packages select *mingw32-make-bin* and *mingw32-gcc-fortran-bin* options. Then click *Installation* in the upper-right corner and select *Apply changes*.

 * If you installed MinGW, add it to the `PATH` variables. First go to Windows Settings (Control Panel). In the search box start typing "environment" and select *Edit environment variables for your account*. In the first box select *PATH* and click *EDIT*. Click *New* and then *Browse* and navigate to *MinGW* installation folder and select bin. An example would be `C:\MinGW\bin`. Finally click *OK* and *OK* again.

### Installing on MacOS

Install GNU Fortran compiler.

``` zsh
brew install gcc
```

### Installing on Linux

Install GNU Fortran compiler.

``` sh
sudo apt update

sudo apt install build-essential

sudo apt-get install manpages-dev

sudo apt install gfortran
```


## Contribution

If you like this project and think you can contribute, please do not hesitate to contact me.










