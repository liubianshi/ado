# Stata ado file for personal use

# Installation

1. 确定此 ado 文件的存放路径

    假设存放在当前文件夹下的 `<parentpath>/adopersonal` 目录, 那么可以采用如下命令，保存

    ```bash
    cd "<parentpath>"
    git clone https//github.com/liubianshi/ado.git adoperonal
    ```

    当然也可以直接从 [liubianshi/ado](https//github.com/liubianshi/ado) 下载压
    缩包，然后解压到指定目录

2. 确定 Stata 目录的位置

    打开 stata 软件，输入 `sysdir`, STATA 对应的位置就是 Stata 系统目录对应的位置

    ![stata-sys-dir](img/stata-dir.png)

3. 编辑该目录下的文件 `profile.do`, 在开头加入如下代码，`<parentpath>` 用第一
   步的存放目录替代。

    ```stata
    adopath + "<parentpath>"
    ```

4. 打开 stata 应用，在命令行输入 `test_hello_world`, 如果返回 "Hello World"，
   说明安装成功，否则，前面的路径设置可能有问题。






