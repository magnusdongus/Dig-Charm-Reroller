#SingleInstance Force
#Requires AutoHotkey v2.0
#MaxThreadsPerHotkey 2
SendMode("Input")
SetDefaultMouseSpeed(0)

settingsFile := A_ScriptDir . "\CharmReroller.ini"
clicking := false
pencilX := 0, pencilY := 0
yesX := 0, yesY := 0
delay := 1
ssTargetCount := 2
ssX1 := 0, ssY1 := 0, ssX2 := 0, ssY2 := 0
ssAreaSet := false
rerollCount := 0
robloxWindow := ""
settingMode := ""

gradeCounters := {
    F: 0, D: 0, C: 0, B: 0, A: 0, S: 0, SS: 0
}

gradeColors := {
    F: 0xA5ABB6,    ; Gray F
    D: 0x95B1F3,    ; Blue D
    C: 0x69FF82,    ; Green C
    B: 0x9386FE,    ; Darker Blue B
    A: 0xFFC942,    ; Gold A
    S: 0xFF3866,    ; Red S
    SS: 0xFF82AE    ; Pink SS
}

discordWebhookUrl := ""
enableWebhook := false

mainGui := ""
statusText := ""
startBtn := ""
delayEdit := ""
targetEdit := ""
rerollCountText := ""
ssCountText := ""
logText := ""
alwaysOnTopBtn := ""
isAlwaysOnTop := false
pencilBtn := ""
yesBtn := ""
ssAreaBtn := ""
testBtn := ""
pencilIndicator := ""
yesIndicator := ""
ssAreaIndicator := ""
webhookUrlEdit := ""
webhookToggle := ""
gradeDisplayText := ""

CreateGUI()
FindRobloxWindow()

F1::ToggleRerolling()
F8::TestGradeDetection()
Esc::ExitApp
~LButton::HandleMouseClick()
~RButton::CancelSetting()

CreateGUI() {
    global
    
    mainGui := Gui("+Resize -MaximizeBox", "Dig Charm Reroller - By Yark Spade")
    mainGui.BackColor := "0x1e1e1e"
    mainGui.OnEvent("Close", (*) => ExitApp())
    
    textColor := "0xffffff"
    
    alwaysOnTopBtn := mainGui.Add("Button", "x400 y10 w60 h25", "Pin")
    alwaysOnTopBtn.OnEvent("Click", (*) => ToggleAlwaysOnTop())
    alwaysOnTopBtn.SetFont("s8", "Segoe UI")
    
    title := mainGui.Add("Text", "x20 y10 w370 h30 Center c" . textColor, "Dig Charm Reroller")
    title.SetFont("s14 Bold", "Segoe UI")
    
    statusGroup := mainGui.Add("GroupBox", "x20 y45 w440 h90 c" . textColor, " Status ")
    statusGroup.SetFont("s9 Bold", "Segoe UI")
    
    statusText := mainGui.Add("Text", "x30 y65 w420 h20 Center c" . textColor, "Ready - Set up positions to begin")
    statusText.SetFont("s9", "Segoe UI")
    
    rerollCountText := mainGui.Add("Text", "x30 y90 w200 h20 c" . textColor, "Rerolls: 0")
    rerollCountText.SetFont("s9", "Segoe UI")
    
    ssCountText := mainGui.Add("Text", "x250 y90 w200 h40 c" . textColor, "F:0 D:0 C:0 B:0 A:0 S:0 SS:0")
    ssCountText.SetFont("s9", "Segoe UI")
    
    gradeDisplayText := mainGui.Add("Text", "x30 y110 w420 h20 c" . textColor, "Last Roll: -")
    gradeDisplayText.SetFont("s8", "Segoe UI")
    
    webhookGroup := mainGui.Add("GroupBox", "x20 y140 w440 h70 c" . textColor, " Discord Webhook ")
    webhookGroup.SetFont("s9 Bold", "Segoe UI")
    
    mainGui.Add("Text", "x30 y160 w80 h20 c" . textColor, "Webhook URL:")
    webhookUrlEdit := mainGui.Add("Edit", "x115 y158 w250 h20", "")
    webhookUrlEdit.OnEvent("Change", UpdateWebhookUrl)
    
    webhookToggle := mainGui.Add("Button", "x375 y158 w75 h20", "Disabled")
    webhookToggle.OnEvent("Click", (*) => ToggleWebhook())
    
    mainGui.Add("Text", "x30 y180 w420 h20 c0x888888", "Paste your Discord webhook URL above and click to enable notifications")
    
    configGroup := mainGui.Add("GroupBox", "x20 y215 w440 h145 c" . textColor, " Configuration ")
    configGroup.SetFont("s9 Bold", "Segoe UI")
    
    mainGui.Add("Text", "x30 y240 w80 h20 c" . textColor, "Click Delay (ms):")
    delayEdit := mainGui.Add("Edit", "x115 y238 w70 h20 Number", delay)
    delayEdit.OnEvent("Change", UpdateDelay)
    
    mainGui.Add("Text", "x230 y240 w80 h20 c" . textColor, "Target SS:")
    targetEdit := mainGui.Add("Edit", "x290 y238 w70 h20 Number", ssTargetCount)
    targetEdit.OnEvent("Change", UpdateTarget)
    
    pencilBtn := mainGui.Add("Button", "x30 y265 w95 h25", "Pencil")
    pencilBtn.OnEvent("Click", (*) => StartSettingPosition("pencil"))
    
    yesBtn := mainGui.Add("Button", "x135 y265 w95 h25", "Yes Button")
    yesBtn.OnEvent("Click", (*) => StartSettingPosition("yes"))
    
    ssAreaBtn := mainGui.Add("Button", "x240 y265 w95 h25", "Grade Area")
    ssAreaBtn.OnEvent("Click", (*) => StartSettingPosition("ss_area"))
    
    testBtn := mainGui.Add("Button", "x345 y265 w95 h25", "Test Grades")
    testBtn.OnEvent("Click", (*) => TestGradeDetection())
    
    pencilIndicator := mainGui.Add("Text", "x30 y295 w200 h20 c0x888888", "Pencil: Not set")
    yesIndicator := mainGui.Add("Text", "x30 y315 w200 h20 c0x888888", "Yes: Not set")
    ssAreaIndicator := mainGui.Add("Text", "x30 y335 w200 h20 c0x888888", "Grade Area: Not set")
    
    controlGroup := mainGui.Add("GroupBox", "x20 y365 w440 h60 c" . textColor, " Controls ")
    controlGroup.SetFont("s9 Bold", "Segoe UI")
    
    startBtn := mainGui.Add("Button", "x70 y385 w100 h30", "Start (F1)")
    startBtn.OnEvent("Click", (*) => ToggleRerolling())
    startBtn.SetFont("s9 Bold", "Segoe UI")
    
    stopBtn := mainGui.Add("Button", "x180 y385 w100 h30", "Stop (F1)")
    stopBtn.OnEvent("Click", (*) => StopRerolling())
    stopBtn.SetFont("s9", "Segoe UI")
    
    resetBtn := mainGui.Add("Button", "x290 y385 w100 h30", "Reset")
    resetBtn.OnEvent("Click", (*) => ResetCounters())
    resetBtn.SetFont("s9", "Segoe UI")
    
    logGroup := mainGui.Add("GroupBox", "x20 y435 w440 h140 c" . textColor, " Activity Log ")
    logGroup.SetFont("s9 Bold", "Segoe UI")
    
    logText := mainGui.Add("Edit", "x30 y455 w420 h110 ReadOnly VScroll c" . textColor " Background0x2d2d2d")
    logText.SetFont("s8", "Consolas")

    LoadSettings()
    UpdatePositionDisplay()
    
    mainGui.Show("w480 h595")
    
    AddLog("GUI initialized - Click position buttons to set up")
    UpdatePositionDisplay()
}

SaveSettings() {
    global settingsFile, discordWebhookUrl, pencilX, pencilY, yesX, yesY, ssX1, ssY1, ssX2, ssY2, ssAreaSet
    
    IniWrite(discordWebhookUrl, settingsFile, "General", "WebhookUrl")
    
    IniWrite(pencilX, settingsFile, "Positions", "PencilX")
    IniWrite(pencilY, settingsFile, "Positions", "PencilY")
    IniWrite(yesX, settingsFile, "Positions", "YesX")
    IniWrite(yesY, settingsFile, "Positions", "YesY")
    
    IniWrite(ssX1, settingsFile, "GradeArea", "X1")
    IniWrite(ssY1, settingsFile, "GradeArea", "Y1")
    IniWrite(ssX2, settingsFile, "GradeArea", "X2")
    IniWrite(ssY2, settingsFile, "GradeArea", "Y2")
    IniWrite(ssAreaSet, settingsFile, "GradeArea", "AreaSet")
}

LoadSettings() {
    global settingsFile, discordWebhookUrl, pencilX, pencilY, yesX, yesY, ssX1, ssY1, ssX2, ssY2, ssAreaSet, webhookUrlEdit
    
    if (!FileExist(settingsFile))
        return
    
    try {
        discordWebhookUrl := IniRead(settingsFile, "General", "WebhookUrl", "")
        if (discordWebhookUrl != "" && webhookUrlEdit)
            webhookUrlEdit.Text := discordWebhookUrl
        
        pencilX := Integer(IniRead(settingsFile, "Positions", "PencilX", 0))
        pencilY := Integer(IniRead(settingsFile, "Positions", "PencilY", 0))
        yesX := Integer(IniRead(settingsFile, "Positions", "YesX", 0))
        yesY := Integer(IniRead(settingsFile, "Positions", "YesY", 0))
        
        ssX1 := Integer(IniRead(settingsFile, "GradeArea", "X1", 0))
        ssY1 := Integer(IniRead(settingsFile, "GradeArea", "Y1", 0))
        ssX2 := Integer(IniRead(settingsFile, "GradeArea", "X2", 0))
        ssY2 := Integer(IniRead(settingsFile, "GradeArea", "Y2", 0))
        ssAreaSet := (IniRead(settingsFile, "GradeArea", "AreaSet", "0") == "1")
        
        AddLog("Settings loaded from file")
    } catch {
        AddLog("Error loading settings file")
    }
}

UpdateWebhookUrl(*) {
    global discordWebhookUrl, webhookUrlEdit
    discordWebhookUrl := webhookUrlEdit.Text
    if (discordWebhookUrl != "") {
        AddLog("Webhook URL updated")
    }
    SaveSettings()
}

ToggleWebhook() {
    global enableWebhook, webhookToggle, discordWebhookUrl
    
    if (discordWebhookUrl == "") {
        AddLog("ERROR: Please enter a webhook URL first!")
        return
    }
    
    enableWebhook := !enableWebhook
    
    if (enableWebhook) {
        webhookToggle.Text := "Enabled"
        webhookToggle.Opt("c0x00ff00")
        AddLog("Discord webhook enabled")
    } else {
        webhookToggle.Text := "Disabled"
        webhookToggle.Opt("c0xffffff")
        AddLog("Discord webhook disabled")
    }
}

SendDiscordWebhook(message) {
    global discordWebhookUrl, enableWebhook
    
    if (!enableWebhook || discordWebhookUrl == "") {
        return
    }
    
    try {
        escapedMessage := EscapeJsonString(message)
        jsonPayload := '{"content": "' . escapedMessage . '"}'
        
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", discordWebhookUrl, false)
        http.SetRequestHeader("Content-Type", "application/json")
        http.Send(jsonPayload)
        
        if (http.Status != 204) {
            AddLog("Webhook failed: HTTP " . http.Status . " - " . http.ResponseText)
        }
    } catch Error as e {
        AddLog("Webhook error: " . e.Message)
    }
}

EscapeJsonString(str) {
    str := StrReplace(str, "\", "\\")
    str := StrReplace(str, '"', '\"')
    str := StrReplace(str, "`n", "\\n")
    str := StrReplace(str, "`r", "\\r")
    str := StrReplace(str, "`t", "\\t")
    return str
}

StartSettingPosition(mode) {
    global settingMode, ssX1, ssY1, ssX2, ssY2, ssAreaSet

    if (!ActivateRoblox()) {
        AddLog("ERROR: Roblox window not found!")
        UpdateStatus("ERROR: Roblox window not found!")
        return
    }
    
    settingMode := mode
    
    if (mode == "ss_area") {
        ssX1 := 0
        ssY1 := 0
        ssX2 := 0
        ssY2 := 0
        ssAreaSet := false
    }
    
    switch mode {
        case "pencil":
            UpdateStatus("SETTING MODE: Click on the pencil icon...")
            AddLog("Click on the pencil icon in Roblox (Right-click to cancel)")
        case "yes":
            UpdateStatus("SETTING MODE: Click on the Yes button...")
            AddLog("Click on the Yes button in Roblox (Right-click to cancel)")
        case "ss_area":
            UpdateStatus("SETTING MODE: Click to start grade area selection...")
            AddLog("Click to start grade area selection, then click again to finish (Right-click to cancel)")
    }
}

HandleMouseClick() {
    global settingMode, pencilX, pencilY, yesX, yesY, ssX1, ssY1, ssX2, ssY2, ssAreaSet
    
    if (!settingMode || (!WinActive("Roblox") && !WinActive("ahk_exe RobloxPlayerBeta.exe")))
        return
    
    MouseGetPos(&mouseX, &mouseY)
    
    switch settingMode {
        case "pencil":
            pencilX := mouseX
            pencilY := mouseY
            AddLog("Pencil position set: " . pencilX . ", " . pencilY)
            UpdateStatus("Pencil position set successfully")
            
        case "yes":
            yesX := mouseX
            yesY := mouseY
            AddLog("Yes button position set: " . yesX . ", " . yesY)
            UpdateStatus("Yes button position set successfully")
            
        case "ss_area":
            if (ssX1 == 0 && ssY1 == 0) {
                ssX1 := mouseX
                ssY1 := mouseY
                AddLog("Grade area start: " . ssX1 . ", " . ssY1 . " (click again to set end)")
                UpdateStatus("Click again to complete grade area selection...")
                return
            } else {
                ssX2 := mouseX
                ssY2 := mouseY
                
                if (ssX1 > ssX2) {
                    temp := ssX1
                    ssX1 := ssX2
                    ssX2 := temp
                }
                if (ssY1 > ssY2) {
                    temp := ssY1
                    ssY1 := ssY2
                    ssY2 := temp
                }
                
                ssAreaSet := true
                AddLog("Grade area set: " . ssX1 . "," . ssY1 . " to " . ssX2 . "," . ssY2)
                UpdateStatus("Grade detection area set successfully")
            }
    }
    
    if (settingMode != "ss_area" || (ssAreaSet && ssX1 > 0 && ssY1 > 0 && ssX2 > 0 && ssY2 > 0)) {
        settingMode := ""
        mainGui.Restore()
        mainGui.Show()
        UpdatePositionDisplay()
        SaveSettings() 
    }
}

CancelSetting() {
    global settingMode, ssX1, ssY1, ssAreaSet
    
    if (!settingMode || (!WinActive("Roblox") && !WinActive("ahk_exe RobloxPlayerBeta.exe")))
        return
    
    AddLog("Position setting cancelled")
    UpdateStatus("Position setting cancelled")
    
    if (settingMode == "ss_area") {
        ssX1 := ssY1 := 0
        ssAreaSet := false
    }
    
    settingMode := ""
    mainGui.Restore()
    mainGui.Show()
}

UpdatePositionDisplay() {
    global
    
    if (pencilX > 0) {
        pencilIndicator.Text := "Pencil: " . pencilX . ", " . pencilY
        pencilIndicator.SetFont("s8", "Segoe UI")
        pencilIndicator.Opt("c0x00ff00")
    }
    
    if (yesX > 0) {
        yesIndicator.Text := "Yes: " . yesX . ", " . yesY
        yesIndicator.SetFont("s8", "Segoe UI")
        yesIndicator.Opt("c0x00ff00")
    }
    
    if (ssAreaSet) {
        ssAreaIndicator.Text := "Grade Area: " . (ssX2-ssX1) . "x" . (ssY2-ssY1) . " px"
        ssAreaIndicator.SetFont("s8", "Segoe UI")
        ssAreaIndicator.Opt("c0x00ff00")
    }
}

UpdateDelay(*) {
    global delay, delayEdit
    newDelay := delayEdit.Text
    if (IsNumber(newDelay) && newDelay > 0) {
        delay := Integer(newDelay)
        AddLog("Delay updated to: " . delay . "ms")
    }
}

UpdateTarget(*) {
    global ssTargetCount, targetEdit
    newTarget := targetEdit.Text
    if (IsNumber(newTarget) && newTarget > 0) {
        ssTargetCount := Integer(newTarget)
        AddLog("Target SS count updated to: " . ssTargetCount)
    }
}

AddLog(message) {
    global logText
    timeStamp := FormatTime(A_Now, "HH:mm:ss")
    newLine := "[" . timeStamp . "] " . message . "`r`n"
    logText.Text := logText.Text . newLine
    SendMessage(0x115, 7, 0, logText.Hwnd)
}

UpdateStatus(message) {
    global statusText
    statusText.Text := message
}

UpdateCounters() {
    global rerollCountText, ssCountText, rerollCount, gradeCounters
    rerollCountText.Text := "Rerolls: " . rerollCount
    
    gradeDisplay := ""
    for grade in gradeCounters.OwnProps() {
        gradeDisplay .= (gradeDisplay ? " " : "") . grade . ":" . gradeCounters.%grade%
    }
    ssCountText.Text := gradeDisplay
}

ResetCounters() {
    global rerollCount, gradeCounters
    rerollCount := 0
    
    for grade in gradeCounters.OwnProps() {
        gradeCounters.%grade% := 0
    }
    
    UpdateCounters()
    UpdateGradeDisplay()
    AddLog("Counters reset")
    UpdateStatus("Counters reset - Ready to start")
}

UpdateGradeDisplay() {
    global gradeDisplayText
    gradeDisplayText.Text := "Last Roll: -"
}

StopRerolling() {
    global clicking, startBtn
    if (clicking) {
        clicking := false
        SetTimer(RerollLoop, 0)
        startBtn.Text := "Start"
        UpdateStatus("Rerolling stopped by user")
        AddLog("Rerolling stopped by user")
    }
}

ToggleRerolling() {
    global clicking, delay, rerollCount, startBtn, pencilX, pencilY, yesX, yesY, ssTargetCount
    
    clicking := !clicking
    
    if (clicking) {
        if (pencilX == 0 || pencilY == 0) {
            AddLog("ERROR: Pencil position not set!")
            UpdateStatus("ERROR: Set pencil position first")
            clicking := false
            return
        }
        
        if (yesX == 0 || yesY == 0) {
            AddLog("ERROR: Yes button position not set!")
            UpdateStatus("ERROR: Set Yes button position first")
            clicking := false
            return
        }
        
        if (!ActivateRoblox()) {
            AddLog("ERROR: Roblox window not found!")
            UpdateStatus("ERROR: Roblox window not found!")
            clicking := false
            return
        }
        
        rerollCount := 0
        startBtn.Text := "Running"
        UpdateStatus("Rerolling started - Target: " . ssTargetCount . " SS ranks")
        AddLog("Rerolling started - Target: " . ssTargetCount . " SS ranks")
        
        SendDiscordWebhook("Dig Charm Reroller Started - Target: " . ssTargetCount . " SS ranks")
        
        SetTimer(RerollLoop, delay)
    } else {
        startBtn.Text := "Start"
        SetTimer(RerollLoop, 0)
        UpdateStatus("Rerolling stopped")
        AddLog("Rerolling stopped")
    }
}

FindRobloxWindow() {
    global robloxWindow
    robloxWindow := WinExist("Roblox")
    if (!robloxWindow)
        robloxWindow := WinExist("ahk_exe RobloxPlayerBeta.exe")
    return robloxWindow
}

ActivateRoblox() {
    global robloxWindow
    if (!robloxWindow)
        FindRobloxWindow()
    
    if (robloxWindow && WinExist("ahk_id " . robloxWindow)) {
        WinActivate("ahk_id " . robloxWindow)
        Sleep(100)
        return true
    }
    return false
}

ToggleAlwaysOnTop() {
    global mainGui, alwaysOnTopBtn, isAlwaysOnTop
    
    isAlwaysOnTop := !isAlwaysOnTop
    
    if (isAlwaysOnTop) {
        WinSetAlwaysOnTop(1, mainGui.Hwnd)
        alwaysOnTopBtn.Text := "PIN ON"
        AddLog("Always on top enabled")
    } else {
        WinSetAlwaysOnTop(0, mainGui.Hwnd)
        alwaysOnTopBtn.Text := "Pin"
        AddLog("Always on top disabled")
    }
}

TestGradeDetection() {
    global ssAreaSet
    if (!ssAreaSet) {
        AddLog("ERROR: Set grade detection area first!")
        UpdateStatus("ERROR: Set grade detection area first!")
        return
    }
    
    if (!ActivateRoblox()) {
        AddLog("ERROR: Roblox window not found!")
        UpdateStatus("ERROR: Roblox window not found!")
        return
    }
    
    currentGrades := DetectAllGrades()
    gradeText := FormatGradeResults(currentGrades)
    
    AddLog("Grade Detection Test - " . gradeText)
    UpdateStatus("Grade Detection Test - " . gradeText)
    UpdateCounters()
    UpdateGradeDisplay()
}

PerformClick(x, y) {
    global yesX, yesY

    isYesButton := (x == yesX && y == yesY)

    if (!ActivateRoblox()) {
        return false
    }
    
    maxRetries := isYesButton ? 3 : 2
    
    Loop maxRetries {
        offsetX := x + Random(-2, 2)
        offsetY := y + Random(-2, 2)
        MouseMove(offsetX, offsetY, 0)
        
        Sleep(isYesButton ? 50 : 100)
        Click(offsetX, offsetY)
        
        if (A_Index < maxRetries) {
            Sleep(isYesButton ? 100 : 200)
        }
    }
    
    return true
}

DetectAllGrades() {
    global ssX1, ssY1, ssX2, ssY2, ssAreaSet, gradeColors
    
    if (!ssAreaSet)
        return Map()
    
    detectedGrades := Map()
    
    for grade in gradeColors.OwnProps() {
        detectedGrades[grade] := 0
    }
    
    y := ssY1 + 2
    
    while (y < ssY2 - 2) {
        gradeFoundAtThisY := false
        
        x := ssX1 + 2
        while (x < ssX2 - 2) {
            color := PixelGetColor(x, y)
            
            for grade in gradeColors.OwnProps() {
                gradeColor := gradeColors.%grade%
                tolerance := (grade == "F") ? 30 : 40
                
                if (ColorMatch(color, gradeColor, tolerance)) {
                    if (VerifyGradePattern(x, y, gradeColor, grade)) {
                        detectedGrades[grade]++
                        gradeFoundAtThisY := true
                        break
                    }
                }
            }
            
            if (gradeFoundAtThisY) {
                break
            }
            
            x += 3
        }
        
        y += gradeFoundAtThisY ? 22 : 2
    }
    return detectedGrades
}

VerifyGradePattern(centerX, centerY, targetColor, grade := "") {
    matchingPixels := 0
    
    if (grade == "F") {
        Loop 8 {
            checkX := centerX + (A_Index - 4)
            Loop 6 {
                checkY := centerY + (A_Index - 3)
                
                color := PixelGetColor(checkX, checkY)
                if (ColorMatch(color, targetColor, 30)) {
                    matchingPixels++
                }
            }
        }
        return (matchingPixels >= 6)
    } else {
        Loop 10 {
            checkX := centerX + (A_Index - 5)
            Loop 8 {
                checkY := centerY + (A_Index - 4)
                
                color := PixelGetColor(checkX, checkY)
                if (ColorMatch(color, targetColor, 40)) {
                    matchingPixels++
                }
            }
        }
        return (matchingPixels >= 8)
    }
}

FormatGradeResults(grades) {
    global gradeDisplayText
    
    resultParts := []
    
    for grade in grades {
        count := grades[grade]
        if (count > 0) {
            resultParts.Push(count . " " . grade)
        }
    }
    
    displayText := resultParts.Length == 0 ? "No grades detected" : ""
    
    for i, part in resultParts {
        displayText .= (i > 1 ? ", " : "") . part
    }
    
    gradeDisplayText.Text := "Last Roll: " . displayText
    return displayText
}

ColorMatch(color1, color2, tolerance) {
    r1 := color1 >> 16 & 0xFF
    g1 := color1 >> 8 & 0xFF
    b1 := color1 & 0xFF
    
    r2 := color2 >> 16 & 0xFF
    g2 := color2 >> 8 & 0xFF
    b2 := color2 & 0xFF
    
    return (Abs(r1 - r2) <= tolerance && Abs(g1 - g2) <= tolerance && Abs(b1 - b2) <= tolerance)
}

RerollLoop() {
    global clicking, pencilX, pencilY, yesX, yesY, ssTargetCount, ssAreaSet, rerollCount, startBtn, gradeCounters
    
    if (!clicking)
        return
    
    if (!ActivateRoblox()) {
        AddLog("ERROR: Roblox window not found! Stopping...")
        UpdateStatus("ERROR: Roblox window not found! Stopping...")
        clicking := false
        SetTimer(RerollLoop, 0)
        startBtn.Text := "Start"
        return
    }
    
    rerollCount++
    UpdateCounters()
    
    if (!PerformClick(pencilX, pencilY)) {
        AddLog("Failed to click pencil icon")
        UpdateStatus("Failed to click pencil icon")
        return
    }
    
    Sleep(800)
    
    if (!PerformClick(yesX, yesY)) {
        AddLog("Failed to click Yes button")
        UpdateStatus("Failed to click Yes button")
        return
    }
    
    if (ssAreaSet) {
        Sleep(500)
        
        currentGrades := DetectAllGrades()
        currentSSCount := currentGrades.Has("SS") ? currentGrades["SS"] : 0
        
        for grade in currentGrades {
            count := currentGrades[grade]
            gradeCounters.%grade% += count
        }
        
        UpdateCounters()
        gradeText := FormatGradeResults(currentGrades)
        
        if (gradeText != "No grades detected") {
            logMessage := "Reroll #" . rerollCount . " - " . gradeText
            AddLog(logMessage)
            
            webhookMessage := "Reroll #" . rerollCount . " - " . gradeText
            
            if (currentSSCount > 0) {
                webhookMessage .= " | SS Total: " . gradeCounters.SS
                if (currentSSCount >= ssTargetCount) {
                    webhookMessage .= " | TARGET REACHED"
                }
            }
            
            SendDiscordWebhook(webhookMessage)
        } else {
            if (Mod(rerollCount, 10) == 0) {
                webhookMessage := "Reroll #" . rerollCount . " - No grades detected"
                SendDiscordWebhook(webhookMessage)
            }
        }
        
        UpdateStatus("Reroll #" . rerollCount . " - SS: " . gradeCounters.SS)
        
        if (currentSSCount >= ssTargetCount) {
            clicking := false
            SetTimer(RerollLoop, 0)
            startBtn.Text := "Start"
            
            successMsg := "SUCCESS! Found " . currentSSCount . " SS ranks in reroll #" . rerollCount . "!"
            AddLog(successMsg)
            UpdateStatus(successMsg)
            
            totalGradeText := ""
            for grade in gradeCounters.OwnProps() {
                count := gradeCounters.%grade%
                if (count > 0) {
                    totalGradeText .= (totalGradeText ? ", " : "") . count . " " . grade
                }
            }
            
            finalMessage := "Mission Complete! Found " . currentSSCount . " SS ranks on your charm #" . rerollCount . " | Total grades: " . totalGradeText
            SendDiscordWebhook(finalMessage)
            
            SoundPlay("*SystemStart")
            return
        }
    }
}