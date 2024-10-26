/*
    PotPlayer DeepL翻译插件 - 简化版
    文件编码：UTF-8 无BOM
*/

// 支持的语言代码列表
array<string> LangTable = 
{
    "auto", "EN", "ZH"
    // 可以根据需要添加更多语言
};

string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36";

// 获取插件标题
string GetTitle()
{
    return "{$CP949=DeepL 번역$}{$CP950=DeepL 翻譯$}{$CP0=DeepL Translate$}";
}

// 获取插件版本
string GetVersion()
{
    return "1";
}

// 获取插件描述
string GetDesc()
{
    return "DeepL translation plugin for PotPlayer";
}

// 获取源语言列表
array<string> GetSrcLangs()
{
    return LangTable;
}

// 获取目标语言列表
array<string> GetDstLangs()
{
    array<string> ret = LangTable;
    ret.removeAt(0); // 移除 "auto" 选项
    return ret;
}

void OnInitialize()
{
    // 初始化代码（如果需要）
}

void OnFinalize()
{
    // 清理代码（如果需要）
}

string GetLoginTitle()
{
    return "DeepL Login";
}

string GetLoginDesc()
{
    return "Enter DeepL API credentials";
}

string GetUserText()
{
    return "API Key:";
}

string GetPasswordText()
{
    return "";
}

string ServerLogin(string User, string Pass)
{
    // 这里可以添加验证逻辑
    return "200 OK";
}

string ServerLogout()
{
    // 这里可以添加登出逻辑
    return "200 OK";
}

// 简单的JSON解析函数
string JsonParse(string json)
{
    JsonReader Reader;
    JsonValue Root;
    string ret = "";    
    
    if (Reader.parse(json, Root) && Root.isObject())
    {
        JsonValue data = Root["data"];
        if (data.isString())
        {
            ret = data.asString();
        }
    }
    return ret;
}

// 处理特殊字符，将换行、回车和制表符转换为可见的转义序列
string ProcessSpecialChars(string input)
{
    input.replace("\n", "\\n");
    input.replace("\r", "\\r");
    input.replace("\t", "\\t");
    return input;
}

// UTF-8处理测试函数
string TestUTF8Handling(string input)
{
    string result = "UTF-8 处理测试结果:\n\n";
    result += "原始输入: " + input + "\n";
    result += "URL编码后: " + HostUrlEncode(input) + "\n";
    result += "字符数: " + input.length() + "\n";
    result += "特殊字符处理: " + ProcessSpecialChars(input) + "\n";
    return result;
}

// 翻译函数
string Translate(string Text, string &in SrcLang, string &in DstLang)
{
    // HostOpenConsole();  // 取消注释以启用调试控制台

    // 设置编码
    SrcLang = "UTF8";
    DstLang = "UTF8";

    if (SrcLang.length() <= 0) SrcLang = "auto";
    SrcLang.MakeLower();
    
    // 添加RTL标记（如果需要）
    if (DstLang == "ar" || DstLang == "he")
    {
        Text = "\u202B" + Text;
    }

    string testResult = TestUTF8Handling(Text);
    
    string enc = HostUrlEncode(Text);
    
    // 使用 DeepL API
    string url = "http://localhost:1188/translate";
    string postData = "{\"text\":\"" + enc + "\",\"source_lang\":\"" + SrcLang + "\",\"target_lang\":\"" + DstLang + "\"}";
    string headers = "Content-Type: application/json\r\nUser-Agent: " + UserAgent + "\r\nAccept: application/json";
    
    string response = HostUrlGetString(url, headers, postData);
    
    // 返回测试结果和完整的响应
    return testResult + "\n原文: " + Text + "\n\n响应: " + response;
}
