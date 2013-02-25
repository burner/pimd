src = Split("""
src/gui/pimd.d
src/gui/mailwindow.d
""")

env = Environment()
env.Program("pimd", src, DFLAGS = Split("-unittest -gc -g -c -I/usr/include/d/gtkd-2/ -Isrc -gc"), LIBS=["gtkd-2", "phobos2", "pthread", "m", "rt", "dl"])
