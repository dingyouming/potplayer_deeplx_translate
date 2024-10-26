/*
    PotPlayer字幕翻译插件 - 测试版
    功能：使用Google翻译API进行实时字幕翻译
*/

// 支持的语言列表
array<string> LangTable = 
{
    "zh",     // 中文
    "zh-CN",  // 简体中文
    "zh-TW",  // 繁体中文
    "en",     // 英语
    "ja",     // 日语
    "ko"      // 韩语
};

// 基础设置
string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36";
string api_key;

// 插件界面显示相关函数
string GetTitle()
{
    return "{$CP949=测试版翻译$}{$CP950=Test Translate$}{$CP0=Test Translate$}";
}

string GetVersion()
{
    return "1.0";
}

string GetDesc()
{
    return "Google翻译API测试版";
}

// API密钥设置相关函数
string GetLoginTitle()
{
    return "设置翻译API";
}

string GetLoginDesc()
{
    return "请输入Google翻译API密钥";
}

string GetUserText()
{
    return "API密钥:";
}

string GetPasswordText()
{
    return "";
}

// 登录处理函数
string ServerLogin(string User, string Pass)
{
    api_key = User;
    if (api_key.empty()) return "fail";
    return "200 ok";  // 成功必须返回 "200 ok"
}

void ServerLogout()
{
    api_key = "";
}

// 获取支持的语言列表
array<string> GetSrcLangs()
{
    array<string> ret = LangTable;
    ret.insertAt(0, ""); // 添加自动检测选项
    return ret;
}

array<string> GetDstLangs()
{
    return LangTable;
}

// JSON解析函数
string JsonParse(string json)
{
    JsonReader Reader;
    JsonValue Root;
    string ret = "";
    
    if (Reader.parse(json, Root) && Root.isObject())
    {
        // 检查响应状态码
        JsonValue code = Root["code"];
        if (code.isNull() || code.asInt() != 200) {
            return "[翻译服务错误 " + code.asString() + "]";
        }
        
        // 获取翻译结果
        JsonValue data = Root["data"];
        if (data.isString()) {
            ret = data.asString();
        }
        
        // 如果翻译结果为空但有备选项，则使用第一个备选项
        if (ret.empty()) {
            JsonValue alternatives = Root["alternatives"];
            if (alternatives.isArray() && alternatives.size() > 0) {
                ret = alternatives[0].asString();
            }
        }
    }
    
    // 添加错误提示
    if (ret.empty()) {
        if (json.empty()) {
            return "[翻译服务无响应]";
        }
        return "[无法获取翻译结果]";
    }
    
    return ret;
}

// 翻译主函数
string Translate(string Text, string &in SrcLang, string &in DstLang)
{
    //if (Text.empty()) return "";
    
    // 设置源语言
    if (SrcLang.length() <= 0) SrcLang = "auto";
    SrcLang.MakeLower();
    
    // URL编码
    string enc = HostUrlEncode(Text);
    
    // 构建API请求
    string url = "https://translation.googleapis.com/language/translate/v2";
    url += "?target=" + DstLang;
    url += "&q=" + enc;
    if (SrcLang != "auto") url += "&source=" + SrcLang;
    url += "&key=" + api_key;
    
    // 发送请求并获取结果
    string response = HostUrlGetString(url, UserAgent);
    string result = JsonParse(response);
    
    // 设置编码
    if (result.length() > 0)
    {
        SrcLang = "UTF8";
        DstLang = "UTF8";
    }
    
    return result;
}
