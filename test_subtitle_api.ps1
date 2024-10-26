# 测试配置
$apiUrl = "http://localhost:1188/translate"
$testCases = @(
    # 1. 基础功能测试
    @{
        name = "基础翻译测试"
        text = "Hello, world!"
        source = "EN"
        target = "ZH"
        expected = "你好，世界"
    },
    # 2. 长文本测试
    @{
        name = "长文本测试"
        text = "This is a very long subtitle text that might appear in a movie. It contains multiple sentences and might be challenging for the API to handle properly."
        source = "EN"
        target = "ZH"
    },
    # 3. 特殊字符测试
    @{
        name = "特殊字符测试"
        text = "Hello! How are you? (Including special chars: @#$%)"
        source = "EN"
        target = "ZH"
    },
    # 4. 多行字幕测试
    @{
        name = "多行字幕测试"
        text = "First line`nSecond line`nThird line"
        source = "EN"
        target = "ZH"
    },
    # 5. 响应时间测试
    @{
        name = "响应时间测试"
        text = "Quick test for response time"
        source = "EN"
        target = "ZH"
    },
    # 6. 不同语言对测试
    @{
        name = "日语翻译测试"
        text = "こんにちは、世界"
        source = "JA"
        target = "ZH"
    },
    # 7. 空字符串测试
    @{
        name = "空字符串测试"
        text = ""
        source = "EN"
        target = "ZH"
    }
)

# 测试结果统计
$results = @{
    total = 0
    passed = 0
    failed = 0
    performance = @()
}

# 测试函数
function Test-Translation {
    param (
        [Parameter(Mandatory=$true)]
        [hashtable]$testCase
    )

    Write-Host "开始测试用例: $($testCase.name)" -ForegroundColor Cyan
    
    try {
        $body = @{
            text = $testCase.text
            source_lang = $testCase.source
            target_lang = $testCase.target
        } | ConvertTo-Json

        Write-Host "发送请求: $body"
        
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -ContentType "application/json"
        
        Write-Host "收到响应: $($response | ConvertTo-Json)"
        
        # 测试结果处理...
        $results.total++
        Write-Host "`n正在执行测试: $($testCase.name)" -ForegroundColor Cyan

        # 记录性能数据
        $results.performance += @{
            name = $testCase.name
            duration = ($response.Duration - $response.StartTime).TotalMilliseconds
            textLength = $testCase.text.Length
        }

        # 测试结果验证
        $success = $true
        $issues = @()

        # 1. 检查响应码
        if ($response.code -ne 200) {
            $success = $false
            $issues += "响应码不是200"
        }

        # 2. 检查翻译结果是否为空
        if ([string]::IsNullOrEmpty($response.data)) {
            $success = $false
            $issues += "翻译结果为空"
        }

        # 3. 检查响应时间
        if ($response.Duration -gt 2000) {
            $issues += "响应时间超过2秒 ($($response.Duration)ms)"
        }

        # 4. 如果有预期结果，检查是否匹配
        if ($testCase.ContainsKey('expected') -and $response.data -ne $testCase.expected) {
            $success = $false
            $issues += "翻译结果与预期不符"
        }

        # 输出测试结果
        Write-Host "原文: $($testCase.text)"
        Write-Host "译文: $($response.data)"
        Write-Host "响应时间: $($response.Duration)ms"
        
        if ($success) {
            $results.passed++
            Write-Host "测试通过" -ForegroundColor Green
        } else {
            $results.failed++
            Write-Host "测试失败" -ForegroundColor Red
            Write-Host "问题: $($issues -join ', ')"
        }

        # 输出详细信息
        Write-Host "备选翻译: $($response.alternatives -join ', ')"
        Write-Host "翻译方法: $($response.method)"
    }
    catch {
        Write-Host "测试执行出错" -ForegroundColor Red
        Write-Host "错误类型: $($_.Exception.GetType().FullName)"
        Write-Host "错误信息: $($_.Exception.Message)"
        Write-Host "堆栈跟踪: $($_.ScriptStackTrace)"
        $results.failed++
    }
}

# 执行测试
Write-Host "开始执行测试..." -ForegroundColor Yellow
$testCases | ForEach-Object { Test-Translation $_ }

# 输出测试报告
Write-Host "`n测试报告" -ForegroundColor Yellow
Write-Host "总测试数: $($results.total)"
Write-Host "通过数: $($results.passed)" -ForegroundColor Green
Write-Host "失败数: $($results.failed)" -ForegroundColor Red

# 性能分析
$avgDuration = ($results.performance | Measure-Object -Property duration -Average).Average
$maxDuration = ($results.performance | Measure-Object -Property duration -Maximum).Maximum
$minDuration = ($results.performance | Measure-Object -Property duration -Minimum).Minimum

Write-Host "`n性能分析" -ForegroundColor Yellow
Write-Host "平均响应时间: $($avgDuration)ms"
Write-Host "最长响应时间: $($maxDuration)ms"
Write-Host "最短响应时间: $($minDuration)ms"

# 输出建议
Write-Host "`n适用性分析" -ForegroundColor Yellow
if ($avgDuration -lt 1000 -and $results.failed -eq 0) {
    Write-Host "该API适合用作字幕翻译插件" -ForegroundColor Green
    Write-Host "优点:"
    Write-Host "- 响应速度快，平均响应时间小于1秒"
    Write-Host "- 稳定性好，测试案例全部通过"
    Write-Host "- 支持多语言翻译"
    Write-Host "- 提供备选翻译选项"
} else {
    Write-Host "该API可能不太适合用作字幕翻译插件" -ForegroundColor Red
    Write-Host "原因:"
    if ($avgDuration -ge 1000) {
        Write-Host "- 响应时间较长，可能影响观看体验"
    }
    if ($results.failed -gt 0) {
        Write-Host "- 存在失败的测试案例，稳定性有待提高"
    }
}
