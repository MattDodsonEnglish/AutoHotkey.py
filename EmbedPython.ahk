#NoEnv
#Warn, All, MsgBox

global NULL := 0
global EMPTY_STRING := ""
global EMPTY_STRING_INTERN := NULL
global UTF8_ENCODING := "CP65001"
; TODO: Find Python DLL with py.exe or in VIRTUAL_ENV.
global PYTHON_DLL := "c:\Users\Sviatoslav\AppData\Local\Programs\Python\Python38\python38.dll"
global METH_VARARGS := 0x0001
global PYTHON_API_VERSION := 1013

global CALLBACKS := {}

global AHKError
global AHKMethods
global AHKModule
global AHKModule_name

OnExit, OnExitLabel

Main()

; END AUTO-EXECUTE SECTION
return


#Include <Commands>


Main() {
    EnvGet, pythonPath, PYTHONPATH
    if (pythonPath == "") {
        EnvSet, PYTHONPATH, %A_ScriptDir%
    } else {
        EnvSet, PYTHONPATH, % pythonPath ";" A_ScriptDir
    }

    DllCall("LoadLibrary", "Str", PYTHON_DLL)
    PackBuiltinModule()
    DllCall(PYTHON_DLL "\PyImport_AppendInittab"
        , "Ptr", &AHKModule_name
        , "Ptr", RegisterCallback("PyInit_ahk", "C", 0)
        , "Cdecl")
    DllCall(PYTHON_DLL "\Py_Initialize", "Cdecl")

    argv0 := "AutoHotkey.exe"
    packArgs := ["Ptr", &argv0]
    for i, arg in A_Args {
        argv%i% := arg
        packArgs.Push("Ptr")
        packArgs.Push(&argv%i%)
    }
    argc := A_Args.Length() + 1
    Pack(argv, packArgs*)

    execResult := DllCall(PYTHON_DLL "\Py_Main", "Int", argc, "Ptr", &argv, "Cdecl Int")
    if (execResult == 1) {
        ; TODO: Show Python syntax errors.
        End("The interpreter exited due to an exception.")
    } else if (execResult == 2) {
        End("The parameter list does not represent a valid Python command line.")
    }
}

PackBuiltinModule() {
    PackBuiltinMethods()

    ; typedef struct PyModuleDef{
    ;   PyModuleDef_Base m_base;
    ;   const char* m_name;
    ;   const char* m_doc;
    ;   Py_ssize_t m_size;
    ;   PyMethodDef *m_methods;
    ;   struct PyModuleDef_Slot* m_slots;
    ;   traverseproc m_traverse;
    ;   inquiry m_clear;
    ;   freefunc m_free;
    ; } PyModuleDef;

    ; static PyModuleDef AHKModule = {
    ;     PyModuleDef_HEAD_INIT, "ahk", NULL, -1, AHKMethods,
    ;     NULL, NULL, NULL, NULL
    ; };

    global AHKModule_name := EncodeString("_ahk")
    global AHKModule
    Pack(AHKModule
        , "Int64", 1  ; ob_refcnt
        , "Ptr", NULL ; ob_type
        , "Ptr", NULL ; m_init
        , "Int64", 0  ; m_index
        , "Ptr", NULL ; m_copy
        , "Ptr", &AHKModule_name
        , "Ptr", NULL
        , "Int64", -1
        , "Ptr", &AHKMethods
        , "Ptr", NULL
        , "Ptr", NULL
        , "Ptr", NULL
        , "Ptr", NULL)
}

PackBuiltinMethods() {
    ; struct PyMethodDef {
    ;     const char  *ml_name;
    ;     PyCFunction ml_meth;
    ;     int         ml_flags;
    ;     const char  *ml_doc;
    ; };

    ; static PyMethodDef AHKMethods[] = {
    ;     {"call_cmd", AHKCallCmd, METH_VARARGS,
    ;      "docstring blablabla"},
    ;     {NULL, NULL, 0, NULL} // sentinel
    ; };

    global AHKMethod_call_cmd_name := EncodeString("call_cmd")
    global AHKMethod_call_cmd_doc := EncodeString("Execute the given AutoHotkey command.")

    global AHKMethod_set_callback_name := EncodeString("set_callback")
    global AHKMethod_set_callback_doc := EncodeString("Set callback to be called by an AutoHotkey event.")

    global AHKMethods
    Pack(AHKMethods
        ; -- cmd_name
        , "Ptr", &AHKMethod_call_cmd_name
        , "Ptr", RegisterCallback("AHKCallCmd", "C")
        , "Int64", METH_VARARGS
        , "Ptr", &AHKMethod_call_cmd_doc
        ; -- set_callback_name
        , "Ptr", &AHKMethod_set_callback_name
        , "Ptr", RegisterCallback("AHKSetCallback", "C")
        , "Int64", METH_VARARGS
        , "Ptr", &AHKMethod_set_callback_doc
        ; -- sentinel
        , "Ptr", NULL 
        , "Ptr", NULL
        , "Int64", 0
        , "Ptr", NULL)
}

Pack(ByRef var, args*) {
    static typeSizes := {Char: 1, UChar: 1
        , Short: 2, UShort: 2
        , Int: 4 , UInt: 4, Int64: 8
        , Float: 4, Double: 8
        , Ptr: A_PtrSize, UPtr: A_PtrSize}

    cap := 0
    typedValues := []
    typedValue := {}
    for index, param in args {
        if (Mod(index, 2) == 1) {
            ; Type string.
            size := typeSizes[param]
            if (not size) {
                End("Invalid type " param)
            }
            cap += size
            typedValue.Type := param
            typedValue.Size := size
        } else {
            typedValue.Value := param
            typedValues.Push(typedValue)
            typedValue := {}
        }
    }

    VarSetCapacity(var, cap, 0)
    offset := 0
    for index, tv in typedValues {
        NumPut(tv.Value, var, offset, tv.Type)
        offset += tv.Size
    }
}

; static PyObject*
PyInit_ahk() {
    module := DllCall(PYTHON_DLL "\PyModule_Create2"
        , "Ptr", &AHKModule
        , "Int", PYTHON_API_VERSION
        , "Cdecl Ptr")
    if (module == NULL) {
        return NULL
    }

    base := NULL
    dict := NULL
    AHKError := DllCall(PYTHON_DLL "\PyErr_NewException"
        , "AStr", "ahk.Error"
        , "Ptr", base
        , "Ptr", dict
        , "Cdecl Ptr")
    Py_XIncRef(AHKError)

    result := DllCall(PYTHON_DLL "\PyModule_AddObject"
        , "Ptr", module
        , "AStr", "Error"
        , "Ptr", AHKError
        , "Cdecl")
    if (result < 0) {
        ; Adding failed.
        Py_XDecRef(AHKError)
        ; Py_CLEAR(AHKError);
        Py_DecRef(module)
        return NULL
    }

    return module
}

AHKCallCmd(self, args) {
    ; const char *cmd;
    cmd := NULL
    ; Maximum number of AHK command arguments seems to be 11
    arg1 := NULL
    arg2 := NULL
    arg3 := NULL
    arg4 := NULL
    arg5 := NULL
    arg6 := NULL
    arg7 := NULL
    arg8 := NULL
    arg9 := NULL
    arg10 := NULL
    arg11 := NULL

    ; TODO: GetProcAddress of the frequently used functions.
    if (not DllCall(PYTHON_DLL "\PyArg_ParseTuple"
            , "Ptr", args
            , "AStr", "s|sssssssssss:call_cmd"
            , "Ptr", &cmd
            , "Ptr", &arg1
            , "Ptr", &arg2
            , "Ptr", &arg3
            , "Ptr", &arg4
            , "Ptr", &arg5
            , "Ptr", &arg6
            , "Ptr", &arg7
            , "Ptr", &arg8
            , "Ptr", &arg9
            , "Ptr", &arg10
            , "Ptr", &arg11
            , "Cdecl")) {
        return NULL
    }

    cmd := NumGet(cmd) ; Decode number from binary.
    cmd := StrGet(cmd, UTF8_ENCODING) ; Read string from address `cmd`.

    Loop, 11
    {
        if (arg%A_Index% != NULL) {
            arg%A_Index% := NumGet(arg%A_Index%)
            arg%A_Index% := StrGet(arg%A_Index%, UTF8_ENCODING)
        }
    }

    if (not Func("_" cmd)) {
        PyErr_SetString(AHKError, "unknown command " cmd)
        return NULL
    }

    ; TODO: Command may raise an exception. Catch and raise it in Python.
    ; TODO: This arg ladder is duplicated in Commands.ahk. Remove it here.
    if (arg1 == NULL) {
        result := _%cmd%()
    } else if (arg2 == NULL) {
        result := _%cmd%(arg1)
    } else if (arg3 == NULL) {
        result := _%cmd%(arg1, arg2)
    } else if (arg4 == NULL) {
        result := _%cmd%(arg1, arg2, arg3)
    } else if (arg5 == NULL) {
        result := _%cmd%(arg1, arg2, arg3, arg4)
    } else if (arg6 == NULL) {
        result := _%cmd%(arg1, arg2, arg3, arg4, arg5)
    } else if (arg7 == NULL) {
        result := _%cmd%(arg1, arg2, arg3, arg4, arg5, arg6)
    } else if (arg8 == NULL) {
        result := _%cmd%(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    } else if (arg9 == NULL) {
        result := _%cmd%(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    } else if (arg10 == NULL) {
        result := _%cmd%(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    } else if (arg11 == NULL) {
        result := _%cmd%(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    } else {
        result := _%cmd%(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
    }

    return AHKToPython(result)
}

AHKSetCallback(self, args) {
    ; const char *name
    name := NULL
    ; const PyObject *func
    funcPtr := NULL
    if (not DllCall(PYTHON_DLL "\PyArg_ParseTuple"
            , "Ptr", args
            , "AStr", "sO:set_callback"
            , "Ptr", &name
            , "Ptr", &funcPtr
            , "Cdecl")) {
        return NULL
    }
    name := NumGet(name)
    name := StrGet(name, UTF8_ENCODING)
    funcPtr := NumGet(funcPtr)

    if (funcPtr == NULL or not DllCall(PYTHON_DLL "\PyCallable_Check", "Ptr", funcPtr, "Cdecl")) {
        PyErr_SetString(AHKError, "callback function '" name "' is not callable")
        return NULL
    }

    Py_IncRef(funcPtr)
    CALLBACKS[name] := funcPtr

    return Py_BuildNone()
}

AHKToPython(value) {
    if (IsObject(value)) {
        ; TODO: Convert AHK object to Python dict.
        End("Not implemented")
    } else if (IsFunc(value)) {
        ; TODO: Wrap AHK function to be called from Python?
        End("Not implemented")
    } else if (value == "") {
        if (EMPTY_STRING_INTERN == NULL) {
            EMPTY_STRING_INTERN := DllCall(PYTHON_DLL "\PyUnicode_InternFromString", "Ptr", &EMPTY_STRING, "Cdecl Ptr")
        }
        return EMPTY_STRING_INTERN
    } else if (value+0 == value) {
        ; The value is a number.
        return DllCall(PYTHON_DLL "\PyLong_FromLong", "Int", value, "Cdecl Ptr")
    } else {
        ; The value is a string.
        encoded := EncodeString(value)
        return DllCall(PYTHON_DLL "\PyUnicode_FromString", "Ptr", &encoded, "Cdecl Ptr")
    }
}

Py_BuildNone() {
    ; TODO: Cache the pointer to None.
    res := DllCall(PYTHON_DLL "\Py_BuildValue", "AStr", "", "Cdecl Ptr")
    if (res == NULL) {
        End("Cannot build None")
    }
    return res
}

PyErr_SetString(exception, message) {
    encoded := EncodeString(message)
    DllCall(PYTHON_DLL "\PyErr_SetString", "Ptr", AHKError, "Ptr", &encoded)
}

EncodeString(string) {
    ; Convert a UTF-16 string to a UTF-8 one.
    len := StrPut(string, UTF8_ENCODING)
    VarSetCapacity(var, len)
    StrPut(string, &var, UTF8_ENCODING)
    return var
}

Py_IncRef(pyObject) {
    DllCall(PYTHON_DLL "\Py_IncRef", "Ptr", pyObject, "Cdecl")
}

Py_XIncRef(pyObject) {
    if (pyObject != NULL) {
        Py_IncRef(pyObject)
    }
}

Py_DecRef(pyObject) {
    DllCall(PYTHON_DLL "\Py_DecRef", "Ptr", pyObject, "Cdecl")
}

Py_XDecRef(pyObject) {
    if (pyObject != NULL) {
        Py_DecRef(pyObject)
    }
}

Trigger(key, args*) {
    funcObjPtr := CALLBACKS[key]
    if (not funcObjPtr) {
        return
    }
    argsPtr := NULL
    result := DllCall(PYTHON_DLL "\PyObject_CallObject", "Ptr", funcObjPtr, "Ptr", argsPtr, "Cdecl Ptr")
    if (result == "") {
        End("Call to '" key "' callback failed: " ErrorLevel)
    } else if (result == NULL) {
        End("Call to '" key "' callback failed")
    }
}

End(message) {
    ; TODO: Consider replacing some of End invocations with raising Python
    ; exceptions.
    message .= "`nThe application will now exit."
    MsgBox % message
    ExitApp
}

GuiContextMenu:
GuiDropFiles:
GuiEscape:
GuiSize:
OnClipboardChange:
    Trigger(A_ThisLabel)
    return

GuiClose:
OnExitLabel:
    if (Trigger(A_ThisLabel) == 0) {
        return
    }
    DllCall(PYTHON_DLL "\Py_Finalize", "Cdecl")
    ExitApp
    return

HotkeyLabel:
    Trigger("Hotkey " . A_ThisHotkey)
    return

OnMessageClosure(wParam, lParam, msg, hwnd) {
    Trigger("OnMessage " . msg, wParam, lParam, msg, hwnd)
}
