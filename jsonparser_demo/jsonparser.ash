// JSON Parser Module Header
//       jsonparser 0.1.0

 /// JSON type identifier.
 enum JsonTokenType {
  eJSON_Tok_UNDEFINED = 0,
  eJSON_Tok_OBJECT = 1,    /* Object */
  eJSON_Tok_ARRAY = 2,     /* Array */
  eJSON_Tok_STRING = 4,    /* String */
  eJSON_Tok_PRIMITIVE = 8,   /* ther primitive: number, boolean (true/false) or null */
};

/// Negative numbers after parsing can be either error below
enum JsonError {
  eJSON_Error_InsuficientTokens = -1, /* Not enough tokens were provided */
  eJSON_Error_InvalidCharacter = -2,  /* Invalid character inside JSON string */
  eJSON_Error_Partial = -3            /* The string is not a full JSON packet, more bytes expected */
};

/// JSON token description.
managed struct JsonToken {
  /// Type: object, array, string etc.
  JsonTokenType type;
  /// start position in JSON data string
  int start;
  /// end position in JSON data string
  int end;
  /// 0 if it's a leaf value, 1 or bigger if it's a key or object/array
  int size;
  /// if it's a child, position of the parent in the token array
  int parent;
  /// pass the json_string that was parsed and generated this token to recover the string this token refers to
  import String ToString(String json_string);
  /// Utility function for debugging
  import readonly attribute String TypeAsString;
  /// Helper to ease Token Array creation. Ex: JsonToken* t[] = JsonToken.NewArray(token_count);
  import static JsonToken* [] NewArray(int count); // $AUTOCOMPLETESTATICONLY$
};

/// JSON parser, stores the current position in the string being parsed.
managed struct JsonParser {
  /// offset in the JSON string
  int pos;
  /// next token to allocate
  int toknext;
  /// superior token node, e.g. parent object or array
  int toksuper;
  /// Parses a JSON data string into and array of tokens, each describing a single JSON object. Negative return is a JsonError, otherwise it's the number of used tokens.
  import int Parse(String json_string, JsonToken *tokens[], int num_tokens);
  /// Marks the parser for reset, useful if you want to use it again with a different file. Reset only actually happens when Parse is called.
  import void Reset();
  protected bool _IsNotReset;
};
