# jsmnags
JSMN, a JSON minimal parser, ported for Adventure Game Studio.

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

If you want an easier approach, it also packs a more approacheable parser:
```AGS Script
function room_AfterFadeIn()
{
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
}

```
