# jsmnags

[![Build status](https://ci.appveyor.com/api/projects/status/ub23w5v2ga96us0m/branch/main?svg=true)](https://ci.appveyor.com/project/ericoporto/jsonparser/branch/main)

JSMN, a JSON minimal parser, ported for Adventure Game Studio.

## Usage

If you wish to handle things more manually, you can use a thiner parser that is also faster:

```AGS Script
  String json_string = "{ \"name\":\"John\", \"age\":30, \"car\":null }";
  JsonParser* parser = new JsonParser;
  
  int token_count = 8;
  JsonToken* t[] = JsonToken.NewArray(token_count);

  int r = parser.Parse(json_string, t, token_count);

  // now that you have the Tokens, you can use them to parse as you wish!
  if (r < 0) Display("Failed to parse JSON: %d\n", r);
  if (r < 1 || t[0].type != eJSON_Tok_OBJECT) Display("Object expected\n");

  for(int i=0; i<r  ; i++){
    JsonToken* tok = t[i];
    Display(String.Format("%d ; %s ; %d ; %s ; %d ; %d ; %d", 
      i, tok.ToString(json_string), tok.size , tok.TypeAsString,  tok.start ,  tok.end ,  tok.parent ));
  }
  
  Display("JSON Parsing has FINISHED for string\n\n%s", json_string);
```

This module also packs a more approacheable (but less tested) parser:

```AGS Script
  String json_string = "";
  json_string = json_string.Append("{\"squadName\":\"Super squad\",\"formed\":2016,\"active\":true,\"members\":[");
  json_string = json_string.Append("{\"name\":\"Molecule Man\",\"age\":29,\"secretIdentity\":\"Dan Jukes\",\"powers\":[\"Radiation resistance\",\"Radiation blast\"]},");
  json_string = json_string.Append("{\"name\":\"Madam Uppercut\",\"age\":39,\"secretIdentity\":\"Jane Wilson\",\"powers\":[\"Million punch\",\"Super reflexes\"]},");
  json_string = json_string.Append("{\"name\":\"Eternal Flame\",\"age\":100,\"secretIdentity\":\"Unknown\",\"powers\":[\"Immortality\",\"Heat Immunity\",\"Interdimensional jump\"]}]}");

  MiniJsonParser jp;
  jp.Init(json_string); // parse json_string and internally generate the tokens
  
  while(jp.NextToken()) // advance the current token and exit when there are no tokens left
  {    
    if(jp.CurrentTokenIsLeaf)  // usually the interesting information is on the leafs
    {
      Display(String.Format("%s: %s", jp.CurrentFullKey, jp.CurrentTokenAsString));
    }    
  }
  
  Display("JSON Parsing has FINISHED for string\n\n%s", json_string);
```

An [in-game usage is here](https://github.com/ericoporto/manamatch/blob/32d4300039d03c743db0bc1ca59ee92d2b0b5f15/manamatch/Board.asc#L131).

## Script API

### JsonParser

#### `JsonParser.Parse`
```
int JsonParser.Parse(String json_string, JsonToken *tokens[], int num_tokens)
```
Parses a JSON data string into and array of tokens, each describing a single JSON object. Negative return is a `JsonError`, otherwise it's the number of used tokens.

#### `JsonParser.Reset`
```
void JsonParser.Reset()
```
Marks the parser for reset, useful if you want to use it again with a different file. Reset only actually happens when Parse is called.

#### `JsonParser.pos`
```
int JsonParser.pos
```
offset in the JSON string

#### `JsonParser.toknext`
```
int JsonParser.toknext
```
next token to allocate

#### `JsonParser.toksuper`
```
int JsonParser.toksuper
```
superior token node, e.g. parent object or array

### JsonToken

#### `JsonToken.NewArray`
```
static JsonToken* [] JsonToken.NewArray(int count)
```
Static helper to ease Token Array creation. Ex: `JsonToken* t[] = JsonToken.NewArray(token_count);`

#### `JsonToken.ToString`
```
String JsonToken.ToString(String json_string)
```
pass the json_string that was parsed and generated this token to recover the string this token refers to

#### `JsonToken.type`
```
JsonTokenType JsonToken.type
```
The type of the token: object, array, string etc.

#### `JsonToken.start`
```
int JsonToken.start
```
The start position in JSON data string.

#### `JsonToken.end`
```
int JsonToken.end
```
The end position in JSON data string.

#### `JsonToken.size`
```
int JsonToken.size
```
The size tells about the direct children of the token, 0 if it's a leaf value, 1 or bigger if it's a key or object/array.

#### `JsonToken.parent`
```
int JsonToken.parent
```
If it's a child, is the index position of the parent in the token array.

#### `JsonToken.TypeAsString`
```
readonly attribute Strin JsonToken.TypeAsString
```
Utility function for debugging, returns the type of the token in a String format.

### JsonTokenType
- `eJSON_Tok_UNDEFINED`, a valid token should never have this type.
- `eJSON_Tok_OBJECT`, an object, it holds keys and values, values can be any other type.
- `eJSON_Tok_ARRAY`, an array, the token will contain direct ordered children.
- `eJSON_Tok_STRING`, the token is a string, could be a key, could be a value, context is needed.
- `eJSON_Tok_PRIMITIVE`, the token is either a number (float or integer), a boolean (`true` or `false`) or `null`.

### JsonError
Used to check parse results.
- `eJSON_Error_InsuficientTokens`, Not enough tokens were provided. Please use more tokens.
- `eJSON_Error_InvalidCharacter`, Invalid character inside JSON string. 
- `eJSON_Error_Partial`, The string is not a full JSON packet, more bytes expected.

### MiniJsonParser

#### `MiniJsonParser.Init`
```
void MiniJsonParser.Init(String json_string)
```
Initialize the parser passing a JSON as a string. Common usage is: `MiniJsonParser jp; jp.Init(json_string);`.

#### `MiniJsonParser.NextToken`
```
bool MiniJsonParser.NextToken()
```
Advances to the next token. Returns false if no tokens left.

#### `MiniJsonParser.CurrentTokenAsString`
```
readonly attribute String MiniJsonParser.CurrentTokenAsString
```
The current token content, as a String.

#### `MiniJsonParser.CurrentTokenType`
```
readonly attribute JsonTokenType MiniJsonParser.CurrentTokenType
```
The current token type.

#### `MiniJsonParser.CurrentTokenSize`
```
readonly attribute int MiniJsonParser.CurrentTokenSize
```
The current token size, 0 if it's a leaf value, 1 or bigger if it's a key or object/array.

#### `MiniJsonParser.CurrentState`
```
readonly attribute MiniJsonParserState MiniJsonParser.CurrentState
```
The current state of our mini parser. Helps understanding the JSON tokens we got when parsing.

#### `MiniJsonParser.CurrentFullKey`
```
readonly attribute String MiniJsonParser.CurrentFullKey
```
Gets the current dot separated key.

#### `MiniJsonParser.CurrentTokenIsLeaf`
```
readonly attribute bool MiniJsonParser.CurrentTokenIsLeaf
```
Checks if the state and key type currently are a leaf. True if it's, usually leafs are the interesting tokens we want when parsing.

### MiniJsonParserState
- `eJP_State_START`, The parser just started.
- `eJP_State_KEY`, The current token is key in an object.
- `eJP_State_VALUE`, The current token is a value in an object.
- `eJP_State_ARRVALUE`, The current token is a value in an array.
- `eJP_State_STOP`, Don't parse anything in this state, but the parser is not necessarily done.


## License

This code is licensed with MIT [`LICENSE`](LICENSE). The code on this module is based on Serge's JSMN, which is also MIT licensed and is referenced in the license.
