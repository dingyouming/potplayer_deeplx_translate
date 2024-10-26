/*
	real time subtitle translate for PotPlayer using DeepLx API
*/

// void OnInitialize()
// void OnFinalize()
// string GetTitle() 														-> get title for UI
// string GetVersion														-> get version for manage
// string GetDesc()															-> get detail information
// string GetLoginTitle()													-> get title for login dialog
// string GetLoginDesc()													-> get desc for login dialog
// string GetUserText()														-> get user text for login dialog
// string GetPasswordText()													-> get password text for login dialog
// string ServerLogin(string User, string Pass)								-> login
// string ServerLogout()													-> logout
//------------------------------------------------------------------------------------------------
// array<string> GetSrcLangs() 												-> get source language
// array<string> GetDstLangs() 												-> get target language
// string Translate(string Text, string &in SrcLang, string &in DstLang) 	-> do translate !!

string JsonParse(string json)
{
	JsonReader Reader;
	JsonValue Root;
	string ret = "";
	
	if (Reader.parse(json, Root) && Root.isObject())
	{
		// 直接获取 data 字段的值
		JsonValue data = Root["data"];
		
		// data 字段是直接的字符串
		if (data.isString())
		{
			ret = data.asString();
		}
		
		// 如果翻译失败，检查错误码
		JsonValue code = Root["code"];
		if (code.isInt() && code.asInt() != 200)
		{
			return "Translation Error: " + code.asInt();
		}
	} 
	return ret;
}


array<string> LangTable = 
{
	"en",    // 英语
	"zh", // 简体中文
	"es",    // 西班牙语
	"hi",    // 印地语
	"ar"     // 阿拉伯语
};

string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36";

string GetTitle()
{
	return "{$CP949=구글 번역$}{$CP950=DeepLx 翻譯$}{$CP0=DeepLx translate$}";
}

string GetVersion()
{
	return "1";
}

string GetDesc()
{
	return "DeepLx Translate API (http://localhost:1188)";
}

string GetLoginTitle()
{
	return "Input DeepLx API key";
}

string GetLoginDesc()
{
	return "Input DeepLx API key";
}

string GetUserText()
{
	return "API key:";
}

string GetPasswordText()
{
	return "";
}

string api_key;

string ServerLogin(string User, string Pass)
{
	api_key = User;
	if (api_key.empty()) return "fail";
	return "200 ok";
}

void ServerLogout()
{
	api_key = "";
}

array<string> GetSrcLangs()
{
	array<string> ret = LangTable;
	
	ret.insertAt(0, ""); // empty is auto
	return ret;
}

array<string> GetDstLangs()
{
	array<string> ret = LangTable;
	
	return ret;
}

array<string> split(string str, string delimiter) 
{
	array<string> parts;
	int startPos = 0;
	while (true) {
		int index = str.findFirst(delimiter, startPos);
		if ( index == -1 ) {
			parts.insertLast( str.substr(startPos) );
			break;
		}
		else {
			parts.insertLast( str.substr(startPos, index - startPos) );
			startPos = index + delimiter.length();
		}
	}
	return parts;
}

string Translate(string Text, string &in SrcLang, string &in DstLang)
{
	string UNICODE_RLE = "\u202B";
	
	if (SrcLang.length() <= 0) SrcLang = "en";
	
	// 转换为大写以匹配 API 要求
	SrcLang.MakeUpper();  // 改为大写，因为 API 示例中用的是 "EN"
	DstLang.MakeLower();  // 目标语言保持小写，因为 API 示例中用的是 "zh"
	
	// 确保文本被正确转义
	string escapedText = Text;
	escapedText.replace("\\", "\\\\");
	escapedText.replace("\"", "\\\"");
	
	// 构建 JSON 请求体，完全匹配成功的示例格式
	string jsonBody = "{\"text\":\"" + escapedText + "\",\"source_lang\":\"" + SrcLang + "\",\"target_lang\":\"" + DstLang + "\"}";
	
	// DeepLx API 调用
	string url = "http://localhost:1188/translate";
	string SendHeader = "Content-Type: application/json";
	
	string text = HostUrlGetString(url, UserAgent, SendHeader, jsonBody);
	
	if (text.length() > 0)
	{
		string ret = JsonParse(text);
		if (ret.length() > 0)
		{
			if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") ret = UNICODE_RLE + ret;
			SrcLang = "UTF8";
			DstLang = "UTF8";
			return ret;
		}
	}
	
	return "Translation failed";
}
