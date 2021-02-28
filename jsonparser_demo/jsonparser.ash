// JSON Parser Module Header
//       jsonparser 0.1.0

 /// JSON type identifier.
 enum JsonTokenType {
  eJSON_Tok_UNDEFINED = 0,
  eJSON_Tok_OBJECT,    /* Object */
  eJSON_Tok_ARRAY,     /* Array */
  eJSON_Tok_STRING,    /* String */
  eJSON_Tok_PRIMITIVE,   /* ther primitive: number, boolean (true/false) or null */
  eJSON_TokMAX
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

enum MiniJsonParserState {
  eJP_State_START = 0,
  eJP_State_KEY,
  eJP_State_VALUE,
  eJP_State_ARRVALUE,
  eJP_State_STOP,
  eJP_StateMAX
};

struct MiniJsonParser {
  /// Initialize the parser passing a JSON as a string.
  import void Init(String json_string);
  /// Advances to the next token. Returns false if no tokens left.
  import bool NextToken();
  /// The current token content, as a String.
  import readonly attribute String CurrentTokenAsString;
  /// The current token type.
  import readonly attribute JsonTokenType CurrentTokenType;
  /// The current token size, 0 if it's a leaf value, 1 or bigger if it's a key or object/array.
  import readonly attribute int CurrentTokenSize;
  /// The current state of our mini parser. Helps understanding the JSON tokens we got when parsing.
  import readonly attribute MiniJsonParserState CurrentState;
  /// Gets the current dot separated key.
  import readonly attribute String CurrentFullKey;
  /// Checks if the state and key type currently are a leaf. True if it's, usually leafs are the interesting tokens we want when parsing.
  import readonly attribute bool CurrentTokenIsLeaf;

  // a bunch of protected things to hide the complexity of simplicity
  // these are not accessible to the user
  protected String _JsonString;
  protected MiniJsonParserState _State;
  protected int _TokenCount;
  protected JsonToken* _Tokens[];
  protected int _itok;
  protected int _ichildren;

  import protected String _print_children();
  protected int _stk_children_idx;
  protected int _stk_children[32];
  protected int _stk_type[32];
  protected String _stk_keyidx[32];
  import protected void _stk_children_push(int value, JsonTokenType type);
  import protected JsonTokenType _stk_type_head_get();
  import protected int _stk_children_pop();
  import protected int _stk_children_head_get();
  import protected void _stk_children_head_decr();

  import protected String _print_keyidx();
  protected int _stk_keyidx_idx;
  import protected void _stk_keyidx_push(String keyidx);
  import protected void _stk_keyidx_pop();
  import protected void _stk_keyidx_increment();
  import protected String _stk_keyidx_tostring();

  protected int _next_itok;
  protected int _next_ichildren;
  protected int _next_State;
  protected JsonToken* _t;
};
