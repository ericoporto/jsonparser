// JSON Module Header

 /// JSON type identifier.
 enum JsonTokenType {
  eJSON_Tok_UNDEFINED = 0,
  eJSON_Tok_OBJECT = 1,    /* Object */
  eJSON_Tok_ARRAY = 2,     /* Array */
  eJSON_Tok_STRING = 3,    /* String */
  eJSON_Tok_PRIMITIVE = 4  /* ther primitive: number, boolean (true/false) or null */
};

/// Negative numbers after parsing can be either error below
enum JsonError {
  eJSON_Error_NOMEM = -1, /* Not enough tokens were provided */
  eJSON_Error_INVAL = -2, /* Invalid character inside JSON string */
  eJSON_Error_PART = -3   /* The string is not a full JSON packet, more bytes expected */
};

/// JSON token description.
managed struct JsonToken {
  /// Type: object, array, string etc.
  JsonTokenType type;
  /// start position in JSON data string
  int start;
  /// end position in JSON data string
  int end;
  int size;
  int parent;

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
  import int Parse(String js, JsonToken *tokens[], int num_tokens);
};
