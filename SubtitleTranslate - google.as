﻿/*
	real time subtitle translate for PotPlayer using google API
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

string JsonParseOld(string json)
{
	JsonReader Reader;
	JsonValue Root;
	string ret = "";	
	
	if (Reader.parse(json, Root) && Root.isArray())
	{
		for (int i = 0, len = Root.size(); i < len; i++)
		{
			JsonValue child1 = Root[i];
			
			if (child1.isArray())
			{
				for (int j = 0, len = child1.size(); j < len; j++)
				{		
					JsonValue child2 = child1[j];
					
					if (child2.isArray())
					{
						JsonValue item = child2[0];
				
						if (!ret.empty()) ret = ret + "\n";
						if (item.isString()) ret = ret + item.asString();
					}
				}
				break;
			}
		}
	} 
	return ret;
}

string JsonParseNew(string json)
{
	JsonReader Reader;
	JsonValue Root;
	string ret = "";
	
	if (Reader.parse(json, Root) && Root.isObject())
	{
		JsonValue data = Root["data"];
			
		if (data.isObject())
		{
			JsonValue translations = data["translations"];
			
			if (translations.isArray())
			{
				for (int j = 0, len = translations.size(); j < len; j++)
				{		
					JsonValue child1 = translations[j];
					
					if (child1.isObject())
					{
						JsonValue translatedText = child1["translatedText"];
				
						if (!ret.empty()) ret = ret + "\n";
						if (translatedText.isString()) ret = ret + translatedText.asString();
					}
				}
			}
		}
	} 
	return ret;
}

string JsonParse_for_openapi(string json)
{
	JsonReader Reader;
	JsonValue Root;

	if (Reader.parse(json, Root))
	{
		string sub_json = Root[0][2].asString();
		if (Reader.parse(sub_json, Root))
		{
			string ans ="";
			JsonValue translations = Root[1][0][0][5];
			for (int i = 0, len = translations.size(); i < len; i++)
			{
				ans += translations[i][0].asString();
			}
			return ans;
		}
	} 
	return "";
}

array<string> LangTable = 
{
	"af",
	"sq",
	"am",
	"ar",
	"hy",
	"az",
	"eu",
	"be",
	"bn",
	"bs",
	"bg",
	"my",
	"ca",
	"ceb",
	"ny",
	"zh",
	"zh-CN",
	"zh-TW",
	"co",
	"hr",
	"cs",
	"da",
	"nl",
	"en",
	"eo",
	"et",
	"tl",
	"fi",
	"fr",
	"fy",
	"gl",
	"ka",
	"de",
	"el",
	"gu",
	"ht",
	"ha",
	"haw",
	"iw",
	"hi",
	"hmn",
	"hu",
	"is",
	"ig",
	"id",
	"ga",
	"it",
	"ja",
	"jw",
	"kn",
	"kk",
	"km",
	"ko",
	"ku",
	"ky",
	"lo",
	"la",
	"lv",
	"lt",
	"lb",
	"mk",
	"ms",
	"mg",
	"ml",
	"mt",
	"mi",
	"mr",
	"mn",
	"my",
	"ne",
	"no",
	"ps",
	"fa",
	"pl",
	"pt",
	"pa",
	"ro",
	"romanji",
	"ru",
	"sm",
	"gd",
	"sr",
	"st",
	"sn",
	"sd",
	"si",
	"sk",
	"sl",
	"so",
	"es",
	"su",
	"sw",
	"sv",
	"tg",
	"ta",
	"te",
	"th",
	"tr",
	"uk",
	"ur",
	"uz",
	"vi",
	"cy",
	"xh",
	"yi",
	"yo",
	"zu"
};

string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36";
string RPC_ID = 'MkEWBc';

string GetTitle()
{
	return "{$CP949=구글 번역$}{$CP950=Google 翻譯$}{$CP0=Google translate$}";
}

string GetVersion()
{
	return "1";
}

string GetDesc()
{
	return "https://translate.google.com/";
}

string GetLoginTitle()
{
	return "Input google API key";
}

string GetLoginDesc()
{
	return "Input google API key";
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
//HostOpenConsole();	// for debug

	string UNICODE_RLE = "\u202B";
	
	if (SrcLang.length() <= 0) SrcLang = "auto";
	SrcLang.MakeLower();
	
	string enc = HostUrlEncode(Text);
	
//	by new API
	if (api_key.length() > 0)
	{
		string url = "https://translation.googleapis.com/language/translate/v2?target=" + DstLang + "&q=" + enc;
		if (!SrcLang.empty() && SrcLang != "auto") url = url + "&source=" + SrcLang;
		url = url + "&key=" + api_key;
		string text = HostUrlGetString(url, UserAgent);
		string ret = JsonParseNew(text);		
		if (ret.length() > 0)
		{
			if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") ret = UNICODE_RLE + ret;
			SrcLang = "UTF8";
			DstLang = "UTF8";
			return ret;
		}	
	}
	
// use open api(for free)
	string url = "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute?rpcids=" + RPC_ID + "&bl=boq_translate-webserver_20221005.09_p0&soc-app=1&soc-platform=1&soc-device=1&rt=c";
	string post_data1 = "[[[\"MkEWBc\",\"[[\\\"";
	string post_data2 = "\\\",\\\"" + SrcLang + "\\\",\\\"" + DstLang + "\\\",true],[null]]\",null,\"generic\"]]]";
	string enc_text = Text;
	enc_text.replace("\\","\\\\");
	enc_text.replace("\"","\\\"");
	enc_text.replace("\\","\\\\");
	enc_text.replace("\"","\\\"");
	enc_text.replace("\n","\\\\n");
	enc_text.replace("\r","\\\\r");
	enc_text.replace("\t","\\\\t");
	
	string post_data = "f.req=" + HostUrlEncode(post_data1 + enc_text + post_data2);
	string SendHeader = "Content-Type: application/x-www-form-urlencoded";
	string text = HostUrlGetString(url, UserAgent, SendHeader, post_data);
	text.replace("\n","");
	int start_pos = text.findFirst("[[", 0);
	int end_pos = text.findLast("]]", -1);
	if (start_pos >= 0 && end_pos > start_pos)
	{
		text = text.substr(start_pos, end_pos - start_pos);
		end_pos = text.findLast("]]", -1);
		if (end_pos > 0)
		{
			text = text.substr(0, end_pos + 2);
			string ret = JsonParse_for_openapi(text);
			if (ret.length() > 0)
			{
				if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") ret = UNICODE_RLE + ret;
				SrcLang = "UTF8";
				DstLang = "UTF8";
				return ret;
			}
		}
	}
	
//	by old API
	url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=" + SrcLang + "&tl=" + DstLang + "&dt=t&q=" + enc;
	text = HostUrlGetString(url, UserAgent);
	string ret = JsonParseOld(text);
	if (ret.length() > 0)
	{
		if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") ret = UNICODE_RLE + ret;
		SrcLang = "UTF8";
		DstLang = "UTF8";
		return ret;
	}	
	
// by web page	
	url = "https://translate.google.com/m?sl=" + SrcLang + "&tl=" + DstLang + "&q=" + enc;
	ret = HostUrlGetString(url, UserAgent);
	string find = "<div class=\"result-container\">";
	int s = ret.find(find);
	if (s > 0)
	{
		s = s + find.length();
		int e = ret.find("</div>", s);		
		if (e > s)
		{
			SrcLang = "UTF8";
			DstLang = "UTF8";
			return ret.substr(s, e - s); 
		}
	}
	return "";
}
