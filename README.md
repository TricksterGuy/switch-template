# switch-template

A starter template for various Switch homebrew applications. This template is geared specifically towards the Code::Blocks IDE.  This template can also be used without Code::Blocks just use the `Makefile` and directory structure provided.

This is designed to be a simple and fairly minimal setup required to begin developing homebrew for the Nintendo switch system.

## Usage

| Targets     | Action                                                                                    |
| ------------| ----------------------------------------------------------------------------------------- |
| nro         | Builds `<project name>.nro`.
| nso       | Builds `<project name>.nso`. <sup>2</sup>
| nsp         | Builds `<project name>.nsp`. <sup>2</sup>
| elf         | Builds `<project name>.elf`.
| nxlink         | Builds `<project name>.nro` and runs nxlink to send to hbmenu.<sup>1</sup>

**Notes:** 
* <sup>1</sup> This requires setting up your switch's ip address in the `Makefile`
* <sup>2</sup> This requires setting up the APP's json file which should be located in RESOURCES/config.json

## Setting up devkitPro
* Follow the steps installing [devkitPro](https://devkitpro.org/wiki/Getting_Started)

## Code::Blocks Setup
1. Simply open `switch-template.cbp` in Code::Blocks
2. Choose File > Save as user-template and enter a template name.  The project setup is now a user template to create new projects.
3. When creating a new project select File > New > From template and follow the wizard's instructions.
4. Ensure you have the environment variables plugin installed (in linux you can install this by installing the codeblocks-contrib package). Alternatively if you already have set DEVKITPRO/DEVKITARM Environment variables you can skip this.
  a. Choose Settings > Environment and scroll down to the Environment Variables section.
    i. Add `DEVKITPRO` and point it to where devkitpro is installed
    ii. Add `DEVKITARM` and point it to where devkitarm is.

To compile in Code::Blocks simply select your target from the list and click the Gear icon to automatically invoke the `Makefile`

## Creating a new project
1. Make a new Code::Blocks project via a user-template you just created above.  Or simply copy this directory.


[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)
