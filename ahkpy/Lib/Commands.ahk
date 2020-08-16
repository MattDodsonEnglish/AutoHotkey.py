_A_SendLevel() {
    return %A_SendLevel%
}

_BlockInput(Mode) {
    BlockInput %Mode%
}

_Click(Item1="",Item2="",Item3="",Item4="",Item5="",Item6="",Item7="") {
    Click %Item1%,%Item2%,%Item3%,%Item4%,%Item5%,%Item6%,%Item7%
}

_GetClipboard() {
    return Clipboard
}

_SetClipboard(Value) {
    Clipboard := Value
}

_ClipWait(SecondsToWait="",AnyKindOfData="") {
    ClipWait %SecondsToWait%,%AnyKindOfData%
    return ErrorLevel
}

_Control(Cmd,Value="",Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    Control %Cmd%,%Value%,%Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_ControlClick(ControlorPos="",WinTitle="",WinText="",WhichButton="",ClickCount="",Options="",ExcludeTitle="",ExcludeText="") {
    ControlClick %ControlorPos%,%WinTitle%,%WinText%,%WhichButton%,%ClickCount%,%Options%,%ExcludeTitle%,%ExcludeText%
}

_ControlFocus(Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    ControlFocus %Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_ControlGetPos(Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    ControlGetPos X,Y,Width,Height,%Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
    return {X: X, Y: Y, Width: Width, Height: Height}
}

_ControlGet(Cmd,Value="",Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    ControlGet OutputVar,%Cmd%,%Value%,%Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
    return OutputVar
}

_ControlGetFocus(WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    ControlGetFocus OutputVar,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
    return OutputVar
}

_ControlGetText(Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    ControlGetText OutputVar,%Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
    return OutputVar
}

_ControlMove(Control,X,Y,Width,Height,WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    ControlMove %Control%,%X%,%Y%,%Width%,%Height%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_ControlSend(Control="",Keys="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    ControlSend %Control%,%Keys%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_ControlSendRaw(Control="",Keys="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    ControlSendRaw %Control%,%Keys%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_ControlSetText(Control="",NewText="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    ControlSetText %Control%,%NewText%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_CoordMode(Target,Mode="") {
    CoordMode %Target%,%Mode%
}

_Critical(Value="") {
    Critical %Value%
}

_DetectHiddenText(OnOff) {
    DetectHiddenText %OnOff%
}

_DetectHiddenWindows(OnOff) {
    DetectHiddenWindows %OnOff%
}

_Drive(Subcommand,Drive="",Value="") {
    Drive %Subcommand%,%Drive%,%Value%
}

_DriveGet(Cmd,Value="") {
    DriveGet OutputVar,%Cmd%,%Value%
    return OutputVar
}

_DriveSpaceFree(Path) {
    DriveSpaceFree OutputVar,%Path%
    return OutputVar+0
}

_EnvGet(EnvVarName) {
    EnvGet OutputVar,%EnvVarName%
    return OutputVar
}

_FileCreateShortcut(Target,LinkFile,WorkingDir="",Args="",Description="",IconFile="",ShortcutKey="",IconNumber="",RunState="") {
    FileCreateShortcut %Target%,%LinkFile%,%WorkingDir%,%Args%,%Description%,%IconFile%,%ShortcutKey%,%IconNumber%,%RunState%
}

_FileGetAttrib(Filename="") {
    FileGetAttrib OutputVar,%Filename%
    return OutputVar
}

_FileGetShortcut(LinkFile, Target="", Dir="", Args="", Description="", Icon="", IconNum="", RunState="") {
    FileGetShortcut, %LinkFile%, %Target%, %Dir%, %Args%, %Description%, %Icon%, %IconNum%, %RunState%
    return { Target: Target
        , Dir: Dir
        , Args: Args
        , Description: Description
        , Icon: Icon
        , IconNum: IconNum
        , RunState: RunState }
}

_FileGetVersion(Filename="") {
    FileGetVersion OutputVar,%Filename%
    return OutputVar
}

_FileRecycle(FilePattern) {
    FileRecycle %FilePattern%
}

_FileRecycleEmpty(DriveLetter="") {
    FileRecycleEmpty %DriveLetter%
}

_FileSelectFile(Options="",RootDirOFilename="",Prompt="",Filter="") {
    FileSelectFile OutputVar,%Options%,%RootDirOFilename%,%Prompt%,%Filter%
    return OutputVar
}

_FileSelectFolder(StartingFolder="",Options="",Prompt="") {
    FileSelectFolder OutputVar,%StartingFolder%,%Options%,%Prompt%
    return OutputVar
}

_FileSetAttrib(Attributes,FilePattern="",OperateOnFolders="",Recurse="") {
    FileSetAttrib %Attributes%,%FilePattern%,%OperateOnFolders%,%Recurse%
}

_FileSetTime(YYYYMMDDHH24MISS="",FilePattern="",WhichTime="",OperateOnFolders="",Recurse="") {
    FileSetTime %YYYYMMDDHH24MISS%,%FilePattern%,%WhichTime%,%OperateOnFolders%,%Recurse%
}

_GroupActivate(GroupName,R="") {
    GroupActivate %GroupName%,%R%
}

_GroupAdd(GroupName,WinTitle="",WinText="",Label="",ExcludeTitle="",ExcludeText="") {
    GroupAdd %GroupName%,%WinTitle%,%WinText%,%Label%,%ExcludeTitle%,%ExcludeText%
}

_GroupClose(GroupName,Flag="") {
    GroupClose %GroupName%,%Flag%
}

_GroupDeactivate(GroupName,R="") {
    GroupDeactivate %GroupName%,%R%
}

_GuiControl(Subcommand,ControlID,Param3="") {
    GuiControl %Subcommand%,%ControlID%,%Param3%
}

_GuiControlGet(Subcommand="",ControlID="",Param4="") {
    GuiControlGet OutputVar,%Subcommand%,%ControlID%,%Param4%
    return OutputVar
}

_Hotkey(ContextID, KeyName, Func, Options) {
    StringLower, KeyName, KeyName
    if (Func) {
        ; TODO: The order of modifier keys doesn't matter in the KeyName.
        oldFunc := CALLBACKS["Hotkey" ContextID " " KeyName]
        if (oldFunc and Func["pyFunc"] != oldFunc["pyFunc"]) {
            WRAPPED_PYTHON_FUNCTIONS[oldFunc["pyFunc"]] := ""
        }
        CALLBACKS["Hotkey" ContextID " " KeyName] := Func
    }
    Hotkey, %KeyName%,%Func%,%Options%
}

_HotkeySpecial(KeyName, Options) {
    Hotkey, %KeyName%,%Options%
}

_HotkeyContext(Predicate) {
    Hotkey, If, %Predicate%
}

_HotkeyExitContext() {
    Hotkey, If
}

_ImageSearch(X1,Y1,X2,Y2,ImageFile) {
    ImageSearch X,Y,%X1%,%Y1%,%X2%,%Y2%,%ImageFile%
    return {X: X, Y: Y}
}

_Input(Options="",EndKeys="",MatchList="") {
    Input OutputVar,%Options%,%EndKeys%,%MatchList%
    return OutputVar
}

_InputBox(Title="",Prompt="",HIDE="",Width="",Height="",X="",Y="",FontBlank="",Timeout="",Default="") {
    InputBox OutputVar,%Title%,%Prompt%,%HIDE%,%Width%,%Height%,%X%,%Y%,,%Timeout%,%Default%
    return OutputVar
}

_KeyHistory() {
    KeyHistory
}

_KeyWait(KeyName,Options="") {
    KeyWait %KeyName%,%Options%
    return ErrorLevel
}

_ListHotkeys() {
    ListHotkeys
}

_Menu(MenuName,Cmd,P3="",P4="",P5="") {
    Menu %MenuName%,%Cmd%,%P3%,%P4%,%P5%
}

_MouseClick(WhichButton="",X="",Y="",ClickCount="",Speed="",State="",R="") {
    MouseClick %WhichButton%,%X%,%Y%,%ClickCount%,%Speed%,%State%,%R%
}

_MouseClickDrag(WhichButton,X1,Y1,X2,Y2,Speed="",R="") {
    MouseClickDrag %WhichButton%,%X1%,%Y1%,%X2%,%Y2%,%Speed%,%R%
}

_MouseGetPos(Flag="") {
    MouseGetPos X, Y, Win, Control, %Flag%
    return {X: X, Y: Y, Win: Win+0, Control: Control}
}

_MouseMove(X,Y,Speed="",R="") {
    MouseMove %X%,%Y%,%Speed%,%R%
}

_MsgBox(Params*) {
    if (Params.Length() == 0) {
        MsgBox
    } else if (Params.Length() == 1) {
        text := Params[1]
        MsgBox, %text%
    } else {
        options := Params[1]
        title := Params[2]
        text := Params[3]
        timeout := Params[4]
        MsgBox % options,%title%,%text%,%timeout%
    }
}

_Pause(State="",OperateOnUnderlyingThread="") {
    Pause %State%,%OperateOnUnderlyingThread%
}

_PixelGetColor(X,Y,Flags="") {
    PixelGetColor OutputVar,%X%,%Y%,%Flags%
    return OutputVar
}

_PixelSearch(X1,Y1,X2,Y2,ColorID,Variation="",Flags="") {
    PixelSearch X,Y,%X1%,%Y1%,%X2%,%Y2%,%ColorID%,%Variation%,%Flags%
    return {X: X, Y: Y}
}

_PostMessage(Msg,wParam="",lParam="",Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    PostMessage %Msg%,%wParam%,%lParam%,%Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
    return ErrorLevel
}

_Process(Cmd,PIDorName,Param3="") {
    Process %Cmd%,%PIDorName%,%Param3%
}

_Progress(ProgressParam1,SubText="",MainText="",WinTitle="",FontName="") {
    Progress %ProgressParam1%,%SubText%,%MainText%,%WinTitle%,%FontName%
}

_Reload() {
    Reload
}

_Run(Target, WorkingDir="", Flags="") {
    Run %Target%, %WorkingDir%, %Flags%, OutputVar
    return OutputVar
}

_RunAs(User="",Password="",Domain="") {
    RunAs %User%,%Password%,%Domain%
}

_RunWait(Target,WorkingDir="",Flags="") {
    RunWait %Target%, %WorkingDir%, %Flags%
}

_Send(Keys) {
    Send %Keys%
}

_SendEvent(Keys) {
    SendEvent %Keys%
}

_SendInput(Keys) {
    SendInput %Keys%
}

_SendLevel(Level) {
    SendLevel %Level%
}

_SendMessage(Msg,wParam="",lParam="",Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="",Timeout="") {
    SendMessage %Msg%,%wParam%,%lParam%,%Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%,%Timeout%
    return ErrorLevel
}

_SendMode(Mode) {
    SendMode %Mode%
}

_SendPlay(Keys) {
    SendPlay %Keys%
}

_SetCapslockState(State="") {
    SetCapslockState %State%
}

_SetControlDelay(Delay) {
    SetControlDelay %Delay%
}

_SetDefaultMouseSpeed(Speed) {
    SetDefaultMouseSpeed %Speed%
}

_SetKeyDelay(Delay="",PressDuration="",Play="") {
    SetKeyDelay %Delay%,%PressDuration%,%Play%
}

_SetMouseDelay(Delay,Play="") {
    SetMouseDelay %Delay%,%Play%
}

_SetNumLockState(State="") {
    SetNumLockState %State%
}

_SetRegView(RegView) {
    SetRegView %RegView%
}

_SetScrollLockState(State="") {
    SetScrollLockState %State%
}

_SetStoreCapslockMode(OnOrOff) {
    SetStoreCapslockMode %OnOrOff%
}

_SetTimer(Closure, PeriodOnOffDelete:="", Priority:="") {
    SetTimer %Closure%,%PeriodOnOffDelete%,%Priority%
}

_SetTitleMatchMode(Flag) {
    SetTitleMatchMode %Flag%
}

_SetWinDelay(Delay) {
    SetWinDelay %Delay%
}

_Shutdown(Code) {
    Shutdown %Code%
}

_Sleep(DelayInMilliseconds) {
    Sleep %DelayInMilliseconds%
}

_SoundBeep(Frequency="",Duration="") {
    SoundBeep %Frequency%,%Duration%
}

_SoundGet(ComponentType="",ControlType="",DeviceNumber="") {
    SoundGet OutputVar, %ComponentType%, %ControlType%, %DeviceNumber%
    static STRING_CONTROL_TYPES := {ONOFF:1, MUTE:1, MONO:1, LOUDNESS:1, STEREOENH:1, BASSBOOST:1}
    if (STRING_CONTROL_TYPES.HasKey(ControlType)) {
        return OutputVar
    } else {
        return OutputVar+0
    }
}

_SoundGetWaveVolume(DeviceNumber="") {
    SoundGetWaveVolume OutputVar,%DeviceNumber%
    return OutputVar+0
}

_SoundPlay(Filename,Wait="") {
    SoundPlay %Filename%,%Wait%
}

_SoundSet(NewSetting,ComponentType="",ControlType="",DeviceNumber="") {
    SoundSet %NewSetting%,%ComponentType%,%ControlType%,%DeviceNumber%
}

_SoundSetWaveVolume(Percent,DeviceNumber="") {
    SoundSetWaveVolume %Percent%,%DeviceNumber%
}

_SplashImage(Param1,Options="",SubText="",MainText="",WinTitle="",FontName="") {
    SplashImage %Param1%,%Options%,%SubText%,%MainText%,%WinTitle%,%FontName%
}

_SplashTextOff() {
    SplashTextOff
}

_SplashTextOn(Width="",Height="",Title="",Text="") {
    SplashTextOn %Width%,%Height%,%Title%,%Text%
}

_StatusBarGetText(Part="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    StatusBarGetText OutputVar,%Part%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
    return OutputVar
}

_StatusBarWait(BarText="",Seconds="",Part#="",WinTitle="",WinText="",Interval="",ExcludeTitle="",ExcludeText="") {
    StatusBarWait %BarText%,%Seconds%,%Part#%,%WinTitle%,%WinText%,%Interval%,%ExcludeTitle%,%ExcludeText%
    return ErrorLevel
}

_Suspend(Mode="") {
    Suspend %Mode%
}

_SysGet(Subcommand,Param2="") {
    SysGet v, %Subcommand%, %Param2%
    if (Subcommand == "Monitor") {
        return {Left: vLeft, Top: vTop, Right: vRight, Bottom: vBottom}
    } else if (Subcommand == "MonitorName") {
        return v
    } else {
        return v+0
    }
}

_Thread(Subcommand,Param2="",Param3="") {
    Thread %Subcommand%,%Param2%,%Param3%
}

_ToolTip(Text="",X="",Y="",WhichToolTip="") {
    ToolTip %Text%,%X%,%Y%,%WhichToolTip%
}

_TrayTip(Title="",Text="",Seconds="",Options="") {
    TrayTip %Title%,%Text%,%Seconds%,%Options%
}

_WinActivate(WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinActivate %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_WinActivateBottom(WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinActivateBottom %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_WinClose(WinTitle="",WinText="",SecondsToWait="",ExcludeTitle="",ExcludeText="") {
    WinClose %WinTitle%,%WinText%,%SecondsToWait%,%ExcludeTitle%,%ExcludeText%
}

_WinGet(Cmd="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinGet OutputVar,%Cmd%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
    StringLower, Cmd, Cmd
    if (Cmd == "list") {
        a := []
        Loop, %OutputVar%
        {
            a.Insert(OutputVar%A_Index% + 0)
        }
        return a
    }
    return OutputVar
}

_WinGetClass(WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinGetClass OutputVar,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
    return OutputVar
}

_WinGetPos(WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinGetPos X, Y, Width, Height, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
    return {Width: Width, Height: Height, X: X, Y: Y}
}

_WinGetText(WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinGetText OutputVar,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
    return OutputVar
}

_WinGetTitle(WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinGetTitle OutputVar,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
    return OutputVar
}

_WinHide(WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinHide %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_WinKill(WinTitle="",WinText="",SecondsToWait="",ExcludeTitle="",ExcludeText="") {
    WinKill %WinTitle%,%WinText%,%SecondsToWait%,%ExcludeTitle%,%ExcludeText%
}

_WinMaximize(WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinMaximize %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_WinMenuSelectItem(WinTitle,WinText,Menu,SubMenu1="",SubMenu2="",SubMenu3="",SubMenu4="",SubMenu5="",SubMenu6="",ExcludeTitle="",ExcludeText="") {
    WinMenuSelectItem %WinTitle%,%WinText%,%Menu%,%SubMenu1%,%SubMenu2%,%SubMenu3%,%SubMenu4%,%SubMenu5%,%SubMenu6%,%ExcludeTitle%,%ExcludeText%
}

_WinMinimize(WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinMinimize %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_WinMinimizeAll() {
    WinMinimizeAll
}

_WinMinimizeAllUndo() {
    WinMinimizeAllUndo
}

_WinMove(Param1,Param2,X="",Y="",Width="",Height="",ExcludeTitle="",ExcludeText="") {
    WinMove %Param1%,%Param2%,%X%,%Y%,%Width%,%Height%,%ExcludeTitle%,%ExcludeText%
}

_WinRestore(WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinRestore %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_WinSet(Attribute,Value,WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinSet %Attribute%,%Value%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_WinSetTitle(Param1,WinText,NewTitle,ExcludeTitle="",ExcludeText="") {
    WinSetTitle %Param1%,%WinText%,%NewTitle%,%ExcludeTitle%,%ExcludeText%
}

_WinShow(WinTitle="",WinText="",ExcludeTitle="",ExcludeText="") {
    WinShow %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}

_WinWait(WinTitle="",WinText="",Seconds="",ExcludeTitle="",ExcludeText="") {
    WinWait %WinTitle%,%WinText%,%Seconds%,%ExcludeTitle%,%ExcludeText%
    return ErrorLevel
}

_WinWaitActive(WinTitle="",WinText="",Seconds="",ExcludeTitle="",ExcludeText="") {
    WinWaitActive %WinTitle%,%WinText%,%Seconds%,%ExcludeTitle%,%ExcludeText%
    return ErrorLevel
}

_WinWaitClose(WinTitle="",WinText="",Seconds="",ExcludeTitle="",ExcludeText="") {
    WinWaitClose %WinTitle%,%WinText%,%Seconds%,%ExcludeTitle%,%ExcludeText%
    return ErrorLevel
}

_WinWaitNotActive(WinTitle="",WinText="",Seconds="",ExcludeTitle="",ExcludeText="") {
    WinWaitNotActive %WinTitle%,%WinText%,%Seconds%,%ExcludeTitle%,%ExcludeText%
    return ErrorLevel
}
