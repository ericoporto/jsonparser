// JSON Module Header

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
  import String ToString(String json_string);
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
  //import readonly attribute EasyJsonParserState State;

  import void Init(String json_string);
  import bool NextToken();
  import readonly attribute String CurrentTokenAsString;
  import readonly attribute JsonTokenType CurrentTokenType;
  import readonly attribute int CurrentTokenSize;
  import readonly attribute MiniJsonParserState State;
  import readonly attribute String FullKey;

  protected String _JsonString;
  protected MiniJsonParserState _State;
  protected int _TokenCount;
  protected JsonToken* _Tokens[];
  protected int _itok;
  protected int _ichildren;
  protected int _stk_children_idx;
  protected int _stk_children[32];
  protected int _stk_type[32];
  protected String _stk_keyidx[32];
  import protected void _stk_children_push(int value, JsonTokenType type);
  import protected JsonTokenType _stk_type_head_get();
  import protected int _stk_children_pop();
  import protected int _stk_children_head_get();
  import protected void _stk_children_head_set(int value);

  protected int _stk_keyidx_idx;
  import protected void _stk_keyidx_push(String keyidx);
  import protected void _stk_keyidx_pop();
  import protected void _stk_keyidx_increment();
  import protected String _stk_keyidx_tostring();
  protected int _stk_keyidx_schpop;

  protected int _next_itok;
  protected int _next_ichildren;
  protected int _next_State;
  protected JsonToken* _t;
};
