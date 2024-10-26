/*
    PotPlayer字幕翻译插件 - DeepLX版
    功能：使用本地DeepLX服务进行实时字幕翻译
*/

// 支持的语言列表（根据DeepLX支持的语言调整）
array<string> LangTable = 
{
    "zh",    // 中文
    "en",    // 英语
    "ja",    // 日语
    "ko",    // 韩语
    "fr",    // 法语
    "de",    // 德语
    "es",    // 西班牙语
    "ru"     // 俄语
};

// 基础设置
string UserAgent = "Mozilla/5.0";
string api_url = "http://localhost:1188/translate";

// 插件界面显示相关函数
string GetTitle()
{
    return "{$CP949=DeepLX翻译$}{$CP950=DeepLX Translate$}{$CP0=DeepLX Translate$}";
}

string GetVersion()
{
    return "1.0";
}

string GetDesc()
{
    return "本地DeepLX翻译服务";
}

// 不需要登录相关函数，因为是本地服务
string GetLoginTitle()
{
    return "";
}

string GetLoginDesc()
{
    return "";
}

string GetUserText()
{
    return "";
}

string GetPasswordText()
{
    return "";
}

string ServerLogin(string User, string Pass)
{
    return "200 ok";
}

void ServerLogout()
{
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
        JsonValue data = Root["data"];
        if (data.isString())
        {
            ret = data.asString();
        }
    } 
    return ret;
}

// 翻译主函数
string Translate(string Text, string &in SrcLang, string &in DstLang)
{
    if (Text.empty()) return "";
    
    // 设置源语言
    if (SrcLang.length() <= 0) SrcLang = "auto";
    SrcLang.MakeLower();
    DstLang.MakeLower();
    
    // 构建POST数据
    string postData = "{";
    postData += "\"text\":\"" + HostUrlEncode(Text) + "\",";
    postData += "\"source_lang\":\"" + SrcLang + "\",";
    postData += "\"target_lang\":\"" + DstLang + "\"";
    postData += "}";
    
    // 设置请求头
    string headers = "Content-Type: application/json\r\nAccept: application/json";
    
    // 发送POST请求
    string response = HostUrlGetString(
        api_url,        // URL
        UserAgent,      // User Agent
        postData,       // POST data
        headers         // Headers
    );
    
    // 解析结果
    string result = JsonParse(response);
    
    // 设置UTF8编码，避免乱码
    if (result.length() > 0)
    {
        SrcLang = "UTF8";
        DstLang = "UTF8";
    }
    
    return result;
}
