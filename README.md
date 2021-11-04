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


# 命令介绍

## `snappreserve`/`snaprestore`

语法：

```stata
snappreserve [name] [, label]
snaprestore [name]
```

作用：

很多时候，数据处理需要对当前数据做破坏性操作，比如在内存中载入新的数据。
此时，需要临时在内存中保存数据。`preserve` 和 `restore` 提供了不错的解决方案。

但有三个小不足：

1. 不允许嵌套
2. 只能在局部起作用
3. 在交互操作数据时，容易出现错误的 `restore`

Stata 提供了 `snapshot` 作为补充，其功能强大，用起来有些变扭，远不如 `preserve` 和 `restore` 简洁。

`snapshot` 命令在保存 Snapshot 时依赖系统生成的序号，
该序号具体取什么值，在调用命令时很难预测，也不应该去做这种预测。

我们可以借助返回值 `r(snapshot)`, 用 Macro 保存序号，以便恢复数据时调用，
但如果每次保存恢复数据都要这样操作一遍，还是略显麻烦。
如果能够用名称保存，用相应名称恢复就好了。

这就是 `snappreserve` 和 `snaprestore` 存在的价值。例如：

```stata
di "Outer: `=_N'"
snappreserve befor_test, label("keep snapshot before test")
    quietly sysuse auto, clear
    di "Inner: `=_N'"
    snappreserve
        clear
        di "Inner's Inner: `=_N'"
        preserve
            quietly sysuse auto, clear
            quietly keep in 1/10
            di "Inner's Inner's Inner: `=_N'"
        restore
        di "Inner's Inner: `=_N'"
    snaprestore
    di "Inner: `=_N'"
snaprestore befor_test
di "Outer: `=_N'"
```







