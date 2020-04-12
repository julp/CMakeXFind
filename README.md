Target: CMake >= 2.8.3

Licence: BSD-2 clause

CMake modules to find:

    * libraries
        + edit(line)
        + fuse
        + git2
        + hiredis
        + libmemcached
        + mysql(client)
        + pcre
        + sqlite3
    * others
        + re2c (build C or C++ lexer)
        + Varnish (build VMod)

For usage, report to header in Find*.cmake files. (you can grab a single file, they do not depend on each other)

Notes:

In case of conflict on variable names, you can override \<*uppercased package name*>_PUBLIC_VAR_NS (and/or \<*uppercased package name*>_PRIVATE_VAR_NS) **before** including (command find_package) the *package*. Example for SQLite3:

```cmake
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR})

set(SQLITE3_PUBLIC_VAR_NS "FOO")
find_package(SQLite3 REQUIRED)
message("FOO_VERSION = ${FOO_VERSION}") # SQLite version was set as FOO_VERSION instead of regular SQLITE3_VERSION
```

To print all exported variables for debugging, define \<*uppercased package name*>_DEBUG (example: `set(SQLITE3_DEBUG TRUE)`) to true **before** including the *package*.
