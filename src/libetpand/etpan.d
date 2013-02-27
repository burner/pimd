module lietpand.etpan;

import core.stdc.time;
import std.conv;
import std.format;
import std.array;
import std.file;
import std.stdio;

alias void function(size_t , size_t ) progress_function;

alias void function(size_t , size_t , void * ) mailprogress_function;

struct MMAPString {
  char * str;
  size_t len;    
  size_t allocated_len;
  int fd;
  size_t mmapped_size;
  /*
  char * old_non_mmapped_str;
  */
}

/* configure location of mmaped files */
extern(C) void mmap_string_set_tmpdir(const char * directory);

extern(C) MMAPString * mmap_string_new (const char * init);
extern(C) MMAPString * mmap_string_new_len (const char * init,
				  size_t len);   
extern(C) MMAPString * mmap_string_sized_new (size_t dfl_size);
extern(C) void mmap_string_free (MMAPString * str);
extern(C) MMAPString * mmap_string_assign (MMAPString * str,
				 const char * rval);
extern(C) MMAPString * mmap_string_truncate (MMAPString *string,
				   size_t len);    
extern(C) MMAPString * mmap_string_set_size (MMAPString * str,
				   size_t len);
extern(C) MMAPString * mmap_string_insert_len (MMAPString * str,
				     size_t pos,   
				     const char * val,
				     size_t len);  
extern(C) MMAPString * mmap_string_append (MMAPString * str,
				 const char * val);
extern(C) MMAPString * mmap_string_append_len (MMAPString * str,
				     const char * val,
				     size_t len);  
extern(C) MMAPString * mmap_string_append_c (MMAPString * str,
				   char c);
extern(C) MMAPString * mmap_string_prepend (MMAPString * str,
				  const char * val);
extern(C) MMAPString * mmap_string_prepend_c (MMAPString * str,
				    char c);
extern(C) MMAPString * mmap_string_prepend_len (MMAPString * str,
				      const char * val,
				      size_t len);  
extern(C) MMAPString * mmap_string_insert (MMAPString * str,
				 size_t pos,
				 const char * val);
extern(C) MMAPString * mmap_string_insert_c (MMAPString *str,
				   size_t pos,
				   char c);
extern(C) MMAPString * mmap_string_erase(MMAPString * str,
			       size_t pos,    
			       size_t len);   
extern(C) void mmap_string_set_ceil(size_t ceil);


/*
  this is the list of known extensions with the purpose to
  get integer identifers for the extensions.
*/
enum {
  MAILIMAP_EXTENSION_ANNOTATEMORE,  /* the annotatemore-draft */
  MAILIMAP_EXTENSION_ACL,           /* the acl capability */
  MAILIMAP_EXTENSION_UIDPLUS,       /* UIDPLUS */
  MAILIMAP_EXTENSION_QUOTA,         /* quota */
  MAILIMAP_EXTENSION_NAMESPACE,     /* namespace */
  MAILIMAP_EXTENSION_XLIST          /* XLIST (Gmail and Zimbra have this) */
}

/*
  this is a list of extended parser functions. The extended parser
  passes its identifier to the extension parser.
*/
enum {
  MAILIMAP_EXTENDED_PARSER_RESPONSE_DATA,
  MAILIMAP_EXTENDED_PARSER_RESP_TEXT_CODE,
  MAILIMAP_EXTENDED_PARSER_MAILBOX_DATA
}

/*
  this is the extension interface. each extension consists
  of a initial parser and an initial free. the parser is
  passed the calling parser's identifier. based on this
  identifier the initial parser can then decide which
  actual parser to call. free has mailimap_extension_data
  as parameter. if you look at mailimap_extension_data
  you'll see that it contains "type" as one of its
  elements. thus an extension's initial free can call
  the correct actual free to free its data.
*/
struct mailimap_extension_api {
  char * ext_name;
  int ext_id; /* use -1 if this is an extension outside libetpan */

  int function(int calling_parser, mailstream * fd,
            MMAPString * buffer, size_t * indx,
            mailimap_extension_data ** result,
            size_t progr_rate,
            progress_function * progr_fun) ext_parser;

  void function(mailimap_extension_data * ext_data) ext_free;
}

/*
  mailimap_extension_data is a wrapper for values parsed by extensions

  - extension is an identifier for the extension that parsed the value.

  - type is an identifier for the real type of the data.

  - data is a pointer to the real data.
*/
struct mailimap_extension_data {
  mailimap_extension_api * ext_extension;
  int ext_type;
  void * ext_data;
}

int mmap_string_ref(MMAPString * string);
int mmap_string_unref(char * str);

struct clistcell {
  void * data;
  clistcell* previous;
  clistcell* next;
}

alias clistcell clistiter;

struct clist {
  clistcell* first;
  clistcell* last;
  int count;
}

extern(C) clist clist_new();

extern(C) void clist_free(clist*);

//extern(C) clistiter* clist_begin(clist*);

/* Returns an iterator to the last element of the list */
extern(C) clistiter* clist_end(clist*);

/* Returns TRUE if list is empty */
extern(C) int clist_isempty(clist *);

/* Returns the number of elements in the list */
extern(C) int clist_count(clist *);

/* Returns an iterator to the first element of the list */
//extern(C) clistiter* clist_begin(clist *);

/* Returns an iterator to the last element of the list */
extern(C) clistiter* clist_end(clist *);

/* Returns an iterator to the next element of the list */
//extern(C) clistiter* clist_next(clistiter *);

/* Returns an iterator to the previous element of the list */
extern(C) clistiter* clist_previous(clistiter *);

/* Returns the data pointer of this element of the list */
//extern(C) void* clist_content(clistiter*);

/* Inserts this data pointer at the beginning of the list */
//extern(C) int clist_prepend(clist*, void*);

/* Inserts this data pointer at the end of the list */
//extern(C) int clist_append(clist*, void*);

//(((lst)->first==(lst)->last) && ((lst)->last==NULL))
bool clist_isempty(clist* lst) {
	return lst.first == lst.last && lst.last is null;
}

//clist_count(lst)               ((lst)->count)
int clist_count(clist* lst) {
	return lst.count;
}

//clist_begin(lst)               ((lst)->first)
clistcell* clist_begin(clist* lst) {
	return lst.first;
}

//clist_end(lst)                 ((lst)->last)
clistcell* clist_end(clist* lst) {
	return lst.last;
}

//clist_next(iter)               (iter ? (iter)->next : NULL)
clistiter* clist_next(clistiter* iter) {
	return iter ? iter.next : null;
}

//clist_previous(iter)           (iter ? (iter)->previous : NULL)
clistiter* clist_previous(clistiter* iter) {
	return iter ? iter.previous : null;
}

//clist_content(iter)            (iter ? (iter)->data : NULL)
void* clist_content(clistiter* iter) {
	return iter ? iter.data : null;
}

//clist_prepend(lst, data)  (clist_insert_before(lst, (lst)->first, data))
int clist_prepend(clist* lst, void* data) {
	return clist_insert_before(lst, lst.first, data);
}

//clist_append(lst, data)   (clist_insert_after(lst, (lst)->last, data))
int clist_append(clist* lst, void* data) {
	return clist_insert_after(lst, lst.first, data);
}

/* Inserts this data pointer before the element pointed by the iterator */
extern(C) int clist_insert_before(clist *, clistiter *, void *);

/* Inserts this data pointer after the element pointed by the iterator */
extern(C) int clist_insert_after(clist *, clistiter *, void *);

/* Deletes the element pointed by the iterator.
   Returns an iterator to the next element. */
extern(C) clistiter *   clist_delete(clist *, clistiter *);

//typedef void(* clist_func)(void *, void *);

//void clist_foreach(clist * lst, clist_func func, void * data);

extern(C) void clist_concat(clist* dest, clist* src);

extern(C) void* clist_nth_data(clist * lst, int indx);

extern(C) clistiter* clist_nth(clist * lst, int indx);

struct mailimap_msg_att {
  clist* att_list; 	/* list of (struct mailimap_msg_att_item *) */
                	/* != NULL */
  int att_number; 	/* extra field to store the message number,
		     			used for mailimap */
}


struct mailimap_msg_att_dynamic {
  clist* att_list; /* list of (struct mailimap_flag_fetch *) */
  /* can be NULL */
}


struct mailimap_date_time {
  int dt_day;
  int dt_month;
  int dt_year;
  int dt_hour;
  int dt_min;
  int dt_sec;
  int dt_zone;
}

struct mailimap_env_from {
  clist * frm_list; /* list of (struct mailimap_address *) */
                /* can be NULL */
}

struct mailimap_env_cc {
  clist * cc_list; /* list of (struct mailimap_address *), can be NULL */
}

struct mailimap_env_bcc {
  clist * bcc_list; /* list of (struct mailimap_address *), can be NULL */
}

struct mailimap_env_sender {
  clist * snd_list; /* list of (struct mailimap_address *), can be NULL */
}

struct mailimap_env_reply_to {
  clist * rt_list; /* list of (struct mailimap_address *), can be NULL */
}

struct mailimap_env_to {
  clist * to_list; /* list of (struct mailimap_address *), can be NULL */
}

struct mailimap_body {
  int bd_type;
  /* can be MAILIMAP_BODY_1PART or MAILIMAP_BODY_MPART */
  union bd_data_t {
    mailimap_body_type_1part * bd_body_1part; /* can be NULL */
    mailimap_body_type_mpart * bd_body_mpart; /* can be NULL */
  }

  bd_data_t db_data;
}

struct mailimap_body_type_1part {
  int bd_type;
  union bd_data_t {
    mailimap_body_type_basic * bd_type_basic; /* can be NULL */
    mailimap_body_type_msg * bd_type_msg;     /* can be NULL */
    mailimap_body_type_text * bd_type_text;   /* can be NULL */
  }

  bd_data_t bd_data;

 mailimap_body_ext_1part * bd_ext_1part;   /* can be NULL */
}

struct mailimap_body_ext_1part {
  char * bd_md5;   /* can be NULL */
  mailimap_body_fld_dsp * bd_disposition; /* can be NULL */
  mailimap_body_fld_lang * bd_language;   /* can be NULL */
  char * bd_loc; /* can be NULL */
  
  clist * bd_extension_list; /* list of (struct mailimap_body_extension *) */
                               /* can be NULL */
}

struct mailimap_body_type_basic {
  mailimap_media_basic * bd_media_basic; /* != NULL */
  mailimap_body_fields * bd_fields; /* != NULL */
}

/*
  mailimap_body_type_msg is a MIME message part

  - body_fields is the MIME fields of the MIME message part

  - envelope is the list of parsed RFC 822 fields of the MIME message

  - body is the sub-part of the message

  - body_lines is the number of lines of the message part
*/
struct mailimap_body_type_msg {
  mailimap_body_fields * bd_fields; /* != NULL */
  mailimap_envelope * bd_envelope;       /* != NULL */
  mailimap_body * bd_body;               /* != NULL */
  int bd_lines;
}

/*
  mailimap_envelope is the list of fields that can be parsed by
  the IMAP server.

  - date is the (non-parsed) content of the "Date" header field,
    should be allocated with malloc()
  
  - subject is the subject of the message, should be allocated with
    malloc()
  
  - sender is the the parsed content of the "Sender" field

  - reply-to is the parsed content of the "Reply-To" field

  - to is the parsed content of the "To" field

  - cc is the parsed content of the "Cc" field
  
  - bcc is the parsed content of the "Bcc" field
  
  - in_reply_to is the content of the "In-Reply-To" field,
    should be allocated with malloc()

  - message_id is the content of the "Message-ID" field,
    should be allocated with malloc()
*/
struct mailimap_envelope {
  char * env_date;                             	/* can be NULL */
  char * env_subject;                          	/* can be NULL */
  mailimap_env_from * env_from;         		/* can be NULL */
  mailimap_env_sender * env_sender;     		/* can be NULL */
  mailimap_env_reply_to * env_reply_to; 		/* can be NULL */
  mailimap_env_to * env_to;             		/* can be NULL */
  mailimap_env_cc * env_cc;             		/* can be NULL */
  mailimap_env_bcc * env_bcc;           		/* can be NULL */
  char * env_in_reply_to;                      	/* can be NULL */
  char * env_message_id;                       	/* can be NULL */
}

struct mailimap_body_type_text {
  char * bd_media_text;                         /* != NULL */
  mailimap_body_fields * bd_fields; /* != NULL */
  int bd_lines;
}

/*
  mailimap_body_fld_lang is the parsed value of the Content-Language field

  - type is the type of content, this can be MAILIMAP_BODY_FLD_LANG_SINGLE
    if this is a single value or MAILIMAP_BODY_FLD_LANG_LIST if there are
    several values

  - single is the single value if the type is MAILIMAP_BODY_FLD_LANG_SINGLE,
    should be allocated with malloc()

  - list is the list of value if the type is MAILIMAP_BODY_FLD_LANG_LIST,
    all elements of the list should be allocated with malloc()
*/
struct mailimap_body_fld_lang {
  int lg_type;
  union lg_data_t {
    char * lg_single; /* can be NULL */
    clist * lg_list; /* list of string (char *), can be NULL */
  }

  lg_data_t lg_data;
}

/*
  mailimap_body_fields is the MIME fields of a MIME part.
  
  - body_parameter is the list of parameters of Content-Type header field

  - body_id is the value of Content-ID header field, should be allocated
    with malloc()

  - body_description is the value of Content-Description header field,
    should be allocated with malloc()

  - body_encoding is the value of Content-Transfer-Encoding header field
  
  - body_disposition is the value of Content-Disposition header field

  - body_size is the size of the MIME part
*/
struct mailimap_body_fields {
  mailimap_body_fld_param * bd_parameter; /* can be NULL */
  char * bd_id;                                  /* can be NULL */
  char * bd_description;                         /* can be NULL */
  mailimap_body_fld_enc * bd_encoding;    /* != NULL */
  int bd_size;
}

/*
  mailimap_media_basic is the MIME type

  - type can be MAILIMAP_MEDIA_BASIC_APPLICATION, MAILIMAP_MEDIA_BASIC_AUDIO,
    MAILIMAP_MEDIA_BASIC_IMAGE, MAILIMAP_MEDIA_BASIC_MESSAGE,
    MAILIMAP_MEDIA_BASIC_VIDEO or MAILIMAP_MEDIA_BASIC_OTHER

  - basic_type is defined when type is MAILIMAP_MEDIA_BASIC_OTHER, should
    be allocated with malloc()

  - subtype is the subtype of the MIME type, for example, this is
    "data" in "application/data", should be allocated with malloc()
*/
struct mailimap_media_basic {
  int med_type;
  char * med_basic_type; /* can be NULL */
  char * med_subtype;    /* != NULL */
}

struct mailimap_body_fld_param {
  clist * pa_list; /* list of (struct mailimap_single_body_fld_param *) */
                /* != NULL */
}

/*
  mailimap_body_fld_enc is a parsed value for Content-Transfer-Encoding

  - type is the kind of Content-Transfer-Encoding, this can be
    MAILIMAP_BODY_FLD_ENC_7BIT, MAILIMAP_BODY_FLD_ENC_8BIT,
    MAILIMAP_BODY_FLD_ENC_BINARY, MAILIMAP_BODY_FLD_ENC_BASE64,
    MAILIMAP_BODY_FLD_ENC_QUOTED_PRINTABLE or MAILIMAP_BODY_FLD_ENC_OTHER

  - in case of MAILIMAP_BODY_FLD_ENC_OTHER, this value is defined,
    should be allocated with malloc()
*/

struct mailimap_body_fld_enc {
  int enc_type;
  char * enc_value; /* can be NULL */
}

/*
  mailimap_body_type_mpart is a MIME multipart.

  - body_list is the list of sub-parts.

  - media_subtype is the subtype of the multipart (for example
    in multipart/alternative, this is "alternative")
    
  - body_ext_mpart is the extended fields of the MIME multipart
*/

struct mailimap_body_type_mpart {
  clist * bd_list; /* list of (struct mailimap_body *) */
                     /* != NULL */
  char * bd_media_subtype; /* != NULL */
  mailimap_body_ext_mpart * bd_ext_mpart; /* can be NULL */
}

/*
  mailimap_body_ext_mpart is the extended result part of a multipart
  bodystructure.

  - body_parameter is the list of parameters of Content-Type header field
  
  - body_disposition is the value of Content-Disposition header field

  - body_language is the value of Content-Language header field

  - body_extension_list is the list of extension fields value.
*/
struct mailimap_body_ext_mpart {
  mailimap_body_fld_param * bd_parameter; /* can be NULL */
  mailimap_body_fld_dsp * bd_disposition; /* can be NULL */
  mailimap_body_fld_lang * bd_language;   /* can be NULL */
  char * bd_loc; /* can be NULL */
  clist * bd_extension_list; /* list of (struct mailimap_body_extension *) */
                               /* can be NULL */
}

/*
  mailimap_msg_att_body_section is a MIME part content
  
  - section is the location of the MIME part in the message
  
  - origin_octet is the offset of the requested part of the MIME part
  
  - body_part is the content or partial content of the MIME part,
    should be allocated through a MMAPString

  - length is the size of the content
*/

struct mailimap_msg_att_body_section {
  mailimap_section * sec_section; /* != NULL */
  int sec_origin_octet;
  char * sec_body_part; /* can be NULL */
  size_t sec_length;
}

/*
  mailimap_section is a MIME part section identifier

  section_spec is the MIME section identifier
*/

struct mailimap_section {
  mailimap_section_spec * sec_spec; /* can be NULL */
}

/*
  mailimap_section_spec is a section specification

  - type is the type of the section specification, the value can be
    MAILIMAP_SECTION_SPEC_SECTION_MSGTEXT or
    MAILIMAP_SECTION_SPEC_SECTION_PART

  - section_msgtext is a message/rfc822 part description if type is
    MAILIMAP_SECTION_SPEC_SECTION_MSGTEXT

  - section_part is a body part location in the message if type is
    MAILIMAP_SECTION_SPEC_SECTION_PART
  
  - section_text is a body part location for a given MIME part,
    this can be NULL if the body of the part is requested (and not
    the MIME header).
*/
struct mailimap_section_spec {
  int sec_type;
  union sec_data_t {
    mailimap_section_msgtext * sec_msgtext; /* can be NULL */
    mailimap_section_part * sec_part;       /* can be NULL */
  }
  sec_data_t sec_data;

  mailimap_section_text * sec_text;       /* can be NULL */
}

/*
  mailimap_section_text is the body part location for a given MIME part

  - type can be MAILIMAP_SECTION_TEXT_SECTION_MSGTEXT or
    MAILIMAP_SECTION_TEXT_MIME

  - section_msgtext is the part of the MIME part when MIME type is
    message/rfc822 than can be requested, when type is
    MAILIMAP_TEXT_SECTION_MSGTEXT
*/

struct mailimap_section_text {
  int sec_type;
  mailimap_section_msgtext * sec_msgtext; /* can be NULL */
}

/*
  mailimap_section_msgtext is a message/rfc822 part description
  
  - type is the type of the content part and the value can be
    MAILIMAP_SECTION_MSGTEXT_HEADER, MAILIMAP_SECTION_MSGTEXT_HEADER_FIELDS,
    MAILIMAP_SECTION_MSGTEXT_HEADER_FIELDS_NOT
    or MAILIMAP_SECTION_MSGTEXT_TEXT

  - header_list is the list of headers when type is
    MAILIMAP_SECTION_MSGTEXT_HEADER_FIELDS or
    MAILIMAP_SECTION_MSGTEXT_HEADER_FIELDS_NOT
*/
struct mailimap_section_msgtext {
  int sec_type;
  mailimap_header_list * sec_header_list; /* can be NULL */
}

/*
  mailimap_section_part is the MIME part location in a message
  
  - section_id is a list of number index of the sub-part in the mail structure,
    each element should be allocated with malloc()

*/
struct mailimap_section_part {
  clist * sec_id; /* list of nz-number (uint32_t *) */
                      /* != NULL */
}

/*
  mailimap_header_list is a list of headers that can be specified when
  we want to fetch fields

  - list is a list of header names, each header name should be allocated
    with malloc()
*/
struct mailimap_header_list {
  clist * hdr_list; /* list of astring (char *), != NULL */
}

/*
  mailimap_body_fld_dsp is the parsed value of the Content-Disposition field

  - disposition_type is the type of Content-Disposition
    (usually attachment or inline), should be allocated with malloc()

  - attributes is the list of Content-Disposition attributes
*/

struct mailimap_body_fld_dsp {
  char* dsp_type;                     /* != NULL */
  mailimap_body_fld_param * dsp_attributes; /* can be NULL */
}

struct mailimap_msg_att_static {
  int att_type;
  union att_data_t {
    mailimap_envelope * att_env;            /* can be NULL */
    mailimap_date_time * att_internal_date; /* can be NULL */
    struct attrtc822 {
      char * att_content; /* can be NULL */
      size_t att_length;
    } 
    struct att_rtc822_header {
      char * att_content; /* can be NULL */
      size_t att_length;
    } 
    struct att_rrc822_text {
      char * att_content; /* can be NULL */
      size_t att_length;
    } 
    int att_rfc822_size;
    mailimap_body * att_bodystructure; /* can be NULL */
    mailimap_body * att_body;          /* can be NULL */
    mailimap_msg_att_body_section * att_body_section; /* can be NULL */
    int att_uid;
  }

  att_data_t att_data;
}

struct mailimap_msg_att_item {
  int att_type;
  union att_data_t {
    mailimap_msg_att_dynamic * att_dyn;   /* can be NULL */
    mailimap_msg_att_static * att_static; /* can be NULL */
  }

  att_data_t att_data;
/*
  	public mailimap_msg_att_dynamic* get_att_dyn() { 
		auto r = this.data;
		return cast(mailimap_msg_att_dynamic*)r;
	}

  	public mailimap_msg_att_static* get_att_static() { 
		auto r = this.data;
		return cast(mailimap_msg_att_static*)r;
	}
*/
}

/* this the type of the message attributes */

enum {
  MAILIMAP_MSG_ATT_ITEM_ERROR,   /* on parse error */
  MAILIMAP_MSG_ATT_ITEM_DYNAMIC, /* dynamic message attributes (flags) */
  MAILIMAP_MSG_ATT_ITEM_STATIC   /* static messages attributes
                                    (message content) */
}

/*
  this is the type of static message attribute
*/
enum {
  MAILIMAP_MSG_ATT_ERROR,         /* on parse error */
  MAILIMAP_MSG_ATT_ENVELOPE,      /* this is the fields that can be
                                    parsed by the server */
  MAILIMAP_MSG_ATT_INTERNALDATE,  /* this is the message date kept
                                     by the server */
  MAILIMAP_MSG_ATT_RFC822,        /* this is the message content
                                     (header and body) */
  MAILIMAP_MSG_ATT_RFC822_HEADER, /* this is the message header */
  MAILIMAP_MSG_ATT_RFC822_TEXT,   /* this is the message text part */
  MAILIMAP_MSG_ATT_RFC822_SIZE,   /* this is the size of the message content */
  MAILIMAP_MSG_ATT_BODY,          /* this is the MIME description of
                                     the message */
  MAILIMAP_MSG_ATT_BODYSTRUCTURE, /* this is the MIME description of the
                                     message with additional information */
  MAILIMAP_MSG_ATT_BODY_SECTION,  /* this is a MIME part content */
  MAILIMAP_MSG_ATT_UID            /* this is the message unique identifier */
}

enum {
  MAILIMAP_NO_ERROR = 0,
  MAILIMAP_NO_ERROR_AUTHENTICATED = 1,
  MAILIMAP_NO_ERROR_NON_AUTHENTICATED = 2,
  MAILIMAP_ERROR_BAD_STATE,
  MAILIMAP_ERROR_STREAM,
  MAILIMAP_ERROR_PARSE,
  MAILIMAP_ERROR_CONNECTION_REFUSED,
  MAILIMAP_ERROR_MEMORY,
  MAILIMAP_ERROR_FATAL,
  MAILIMAP_ERROR_PROTOCOL,
  MAILIMAP_ERROR_DONT_ACCEPT_CONNECTION,
  MAILIMAP_ERROR_APPEND,
  MAILIMAP_ERROR_NOOP,
  MAILIMAP_ERROR_LOGOUT,
  MAILIMAP_ERROR_CAPABILITY,
  MAILIMAP_ERROR_CHECK,
  MAILIMAP_ERROR_CLOSE,
  MAILIMAP_ERROR_EXPUNGE,
  MAILIMAP_ERROR_COPY,
  MAILIMAP_ERROR_UID_COPY,
  MAILIMAP_ERROR_CREATE,
  MAILIMAP_ERROR_DELETE,
  MAILIMAP_ERROR_EXAMINE,
  MAILIMAP_ERROR_FETCH,
  MAILIMAP_ERROR_UID_FETCH,
  MAILIMAP_ERROR_LIST,
  MAILIMAP_ERROR_LOGIN,
  MAILIMAP_ERROR_LSUB,
  MAILIMAP_ERROR_RENAME,
  MAILIMAP_ERROR_SEARCH,
  MAILIMAP_ERROR_UID_SEARCH,
  MAILIMAP_ERROR_SELECT,
  MAILIMAP_ERROR_STATUS,
  MAILIMAP_ERROR_STORE,
  MAILIMAP_ERROR_UID_STORE,
  MAILIMAP_ERROR_SUBSCRIBE,
  MAILIMAP_ERROR_UNSUBSCRIBE,
  MAILIMAP_ERROR_STARTTLS,
  MAILIMAP_ERROR_INVAL,
  MAILIMAP_ERROR_EXTENSION,
  MAILIMAP_ERROR_SASL,
  MAILIMAP_ERROR_SSL
}

extern(C) int mailimap_connect(mailimap * session, mailstream * s);

/*
  mailimap_append()

  This function will append a given message to the given mailbox
  by sending an APPEND command.

  @param session       the IMAP session
  @param mailbox       name of the mailbox
  @param flag_list     flags of the message
  @param date_time     timestamp of the message
  @param literal       content of the message
  @param literal_size  size of the message
  
  @return the return code is one of MAILIMAP_ERROR_XXX or
    MAILIMAP_NO_ERROR codes
*/

extern(C) int mailimap_append(mailimap * session, const char * mailbox,
    mailimap_flag_list * flag_list,
    mailimap_date_time * date_time,
    const char* literal, size_t literal_size);

/*
   mailimap_noop()
   
   This function will poll for an event on the server by
   sending a NOOP command to the IMAP server

   @param session IMAP session
   
   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR_XXX codes
*/

extern(C) int mailimap_noop(mailimap * session);

/*
   mailimap_logout()
   
   This function will logout from an IMAP server by sending
   a LOGOUT command.

   @param session IMAP session
  
   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/

extern(C) int mailimap_logout(mailimap * session);

/*
   mailimap_capability()
   
   This function will query an IMAP server for his capabilities
   by sending a CAPABILITY command.

   @param session IMAP session
   @param result  The result of this command is a list of
     capabilities and it is stored into (* result).

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
 */

extern(C) int mailimap_capability(mailimap * session,
			mailimap_capability_data ** result);

/*
   mailimap_check()

   This function will request for a checkpoint of the mailbox by
   sending a CHECK command.
   
   @param session IMAP session

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
 */
extern(C) int mailimap_check(mailimap * session);

/*
   mailimap_close()

   This function will close the selected mailbox by sending
   a CLOSE command.

   @param session IMAP session
   
   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
 */
extern(C) int mailimap_close(mailimap * session);

/*
   mailimap_expunge()

   This function will permanently remove from the selected mailbox
   message that have the \Deleted flag set.

   @param session IMAP session

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_expunge(mailimap * session);

/*
   mailimap_copy()

   This function will copy the given messages from the selected mailbox
   to the given mailbox. 

   @param session IMAP session
   @param set     This is a set of message numbers.
   @param mb      This is the destination mailbox.

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
 */
extern(C) int mailimap_copy(mailimap * session, mailimap_set * set,
    const char * mb);

/*
   mailimap_uid_copy()

   This function will copy the given messages from the selected mailbox
   to the given mailbox. 

   @param session IMAP session
   @param set     This is a set of message unique identifiers.
   @param mb      This is the destination mailbox.

   @return the return code is one of MAILIMAP_ERROR_XXX or
   MAILIMAP_NO_ERROR codes
 */
extern(C) int mailimap_uid_copy(mailimap * session,
    mailimap_set * set, const char * mb);

/*
   mailimap_create()

   This function will create a mailbox.

   @param session IMAP session
   @param mb      This is the name of the mailbox to create.

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_create(mailimap * session, const char * mb);

/*
   mailimap_delete()

   This function will delete a mailox.

   @param session IMAP session
   @param mb      This is the name of the mailbox to delete.

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_delete(mailimap * session, const char * mb);

/*
   mailimap_examine()

   This function will select the mailbox for read-only operations.

   @param session IMAP session
   @param mb      This is the name of the mailbox to select.

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_examine(mailimap * session, const char * mb);

/*
  mailimap_fetch()

  This function will retrieve data associated with the given message
  numbers.
  
  @param session    IMAP session
  @param set        set of message numbers
  @param fetch_type type of information to be retrieved
  @param result     The result of this command is a clist
    and it is stored into (* result). Each element of the clist is a
    (struct mailimap_msg_att *).

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_fetch(mailimap * session, mailimap_set * set,
	       mailimap_fetch_type * fetch_type, clist ** result);

/*
  mailimap_fetch()

  This function will retrieve data associated with the given message
  numbers.
  
  @param session    IMAP session
  @param set        set of message unique identifiers
  @param fetch_type type of information to be retrieved
  @param result     The result of this command is a clist
    and it is stored into (* result). Each element of the clist is a
    (struct mailimap_msg_att *).

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_uid_fetch(mailimap * session,
		   mailimap_set * set, mailimap_fetch_type * fetch_type, clist ** result);

/*
   mailimap_fetch_list_free()
   
   This function will free the result of a fetch command.

   @param fetch_list  This is the clist containing
     (struct mailimap_msg_att *) elements to free.
*/
extern(C) void mailimap_fetch_list_free(clist * fetch_list);

/*
   mailimap_list()

   This function will return the list of the mailbox
   available on the server.

   @param session IMAP session
   @param mb      This is the reference name that informs
     of the level of hierarchy
   @param list_mb mailbox name with possible wildcard
   @param result  This will store a clist of (struct mailimap_mailbox_list *)
     in (* result)
 
   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_list(mailimap * session, const char * mb,
    const char * list_mb, clist ** result);

/*
   mailimap_login()

   This function will authenticate the client.

   @param session   IMAP session
   @param userid    login of the user
   @param password  password of the user

   @return the return code is one of MAILIMAP_ERROR_XXX or
    MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_login(mailimap * session,
    const char * userid, const char * password);

/*
   mailimap_authenticate()
   
   This function will authenticate the client.
   TODO : documentation
*/
extern(C) int mailimap_authenticate(mailimap * session, 
	const char * auth_type,
    const char * server_fqdn,
    const char * local_ip_port,
    const char * remote_ip_port,
    const char * login, const char * auth_name,
    const char * password, const char * realm);


/*
   mailimap_lsub()

   This function will return the list of the mailbox
   that the client has subscribed to.

   @param session IMAP session
   @param mb      This is the reference name that informs
   of the level of hierarchy
   @param list_mb mailbox name with possible wildcard
   @param result  This will store a list of (struct mailimap_mailbox_list *)
   in (* result)
   
   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_lsub(mailimap * session, const char * mb,
		  const char * list_mb, clist ** result);

/*
   mailimap_list_result_free()

   This function will free the clist of (struct mailimap_mailbox_list *)

   @param list  This is the clist to free.
*/
extern(C) void mailimap_list_result_free(clist * list);

/*
   mailimap_rename()

   This function will change the name of a mailbox.

   @param session  IMAP session
   @param mb       current name
   @param new_name new name

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_rename(mailimap * session,
    const char * mb, const char * new_name);

/*
   mailimap_search()

   All mails that match the given criteria will be returned
   their numbers in the result list.

   @param session  IMAP session
   @param charset  This indicates the charset of the strings that appears
   in the searching criteria
   @param key      This is the searching criteria
   @param result   The result is a clist of (uint32_t *) and will be
   stored in (* result).
   
   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_search(
	mailimap * session, const char * charset,
    mailimap_search_key * key, clist ** result);

/*
   mailimap_uid_search()


   All mails that match the given criteria will be returned
   their unique identifiers in the result list.

   @param session  IMAP session
   @param charset  This indicates the charset of the strings that appears
   in the searching criteria
   @param key      This is the searching criteria
   @param result   The result is a clist of (uint32_t *) and will be
   stored in (* result).
   
   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_uid_search(mailimap * session, const char * charset,
    mailimap_search_key * key, clist ** result);

/*
   mailimap_search_result_free()

   This function will free the result of the a search.

   @param search_result   This is a clist of (uint32_t *) returned
     by mailimap_uid_search() or mailimap_search()
*/
extern(C) void mailimap_search_result_free(clist * search_result);

/*
   mailimap_select()

   This function will select a given mailbox so that messages in the
   mailbox can be accessed.
   
   @param session          IMAP session
   @param mb  This is the name of the mailbox to select.

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_select(mailimap * session, const char * mb);

/*
   mailimap_status()

   This function will return informations about a given mailbox.

   @param session          IMAP session
   @param mb               This is the name of the mailbox
   @param status_att_list  This is the list of mailbox information to return
   @param result           List of returned values

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_status(mailimap * session, const char * mb,
		mailimap_status_att_list * status_att_list,
		mailimap_mailbox_data_status ** result);

/*
   mailimap_uid_store()

   This function will alter the data associated with some messages
   (flags of the messages).

   @param session          IMAP session
   @param set              This is a list of message numbers.
   @param store_att_flags  This is the data to associate with the
     given messages
   
   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_store(mailimap * session,
	       mailimap_set * set,
	       mailimap_store_att_flags * store_att_flags);

/*
   mailimap_uid_store()

   This function will alter the data associated with some messages
   (flags of the messages).

   @param session          IMAP session
   @param set              This is a list of message unique identifiers.
   @param store_att_flags  This is the data to associate with the
     given messages
   
   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_uid_store(mailimap * session,
    mailimap_set * set,
    mailimap_store_att_flags * store_att_flags);

/*
   mailimap_subscribe()

   This function adds the specified mailbox name to the
   server's set of "active" or "subscribed" mailboxes.

   @param session   IMAP session
   @param mb        This is the name of the mailbox

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_subscribe(mailimap * session, const char * mb);

/*
   mailimap_unsubscribe()

   This function removes the specified mailbox name to the
   server's set of "active" or "subscribed" mailboxes.

   @param session   IMAP session
   @param mb        This is the name of the mailbox

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_unsubscribe(mailimap * session, const char * mb);

/*
   mailimap_starttls()

   This function starts change the mode of the connection to
   switch to SSL connection.

   @param session   IMAP session

   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR_XXX codes
 */
extern(C) int mailimap_starttls(mailimap * session);

/*
   mailimap_new()

   This function returns a new IMAP session.

   @param progr_rate  When downloading messages, a function will be called
     each time the amount of bytes downloaded reaches a multiple of this
     value, this can be 0.
   @param progr_fun   This is the function to call to notify the progress,
     this can be NULL.

   @return an IMAP session is returned.
 */
extern(C) mailimap * mailimap_new(size_t imap_progr_rate,
    progress_function * imap_progr_fun);

/*
   mailimap_free()

   This function will free the data structures associated with
   the IMAP session.

   @param session   IMAP session
 */
extern(C) void mailimap_free(mailimap * session);

extern(C) int mailimap_send_current_tag(mailimap * session);

extern(C) char * mailimap_read_line(mailimap * session);

extern(C) int mailimap_parse_response(mailimap * session,
    mailimap_response ** result);

extern(C) void mailimap_set_progress_callback(mailimap * session,
                                    mailprogress_function * body_progr_fun,
                                    mailprogress_function * items_progr_fun,
                                    void * context);

/*
  mailimap is an IMAP connection

  - response is a human readable message returned with a reponse,
    must be accessed read-only

  - stream is the connection with the IMAP server

  - stream_buffer is the buffer where the data to parse are stored

  - state is the state of IMAP connection

  - tag is the current tag being used in IMAP connection

  - response_buffer is the buffer for response messages

  - connection_info is the information returned in response
    for the last command about the connection

  - selection_info is the information returned in response
    for the last command about the current selected mailbox

  - response_info is the other information returned in response
    for the last command
*/

struct mailimap {
  char * imap_response;
  
  /* internals */
  mailstream * imap_stream;

  size_t imap_progr_rate;
  progress_function * imap_progr_fun;

  MMAPString * imap_stream_buffer;
  MMAPString * imap_response_buffer;

  int imap_state;
  int imap_tag;

  mailimap_connection_info * imap_connection_info;
  mailimap_selection_info * imap_selection_info;
  mailimap_response_info * imap_response_info;
  
  struct imap_sasl_t {
    void * sasl_conn;
    const char * sasl_server_fqdn;
    const char * sasl_login;
    const char * sasl_auth_name;
    const char * sasl_password;
    const char * sasl_realm;
    void * sasl_secret;
  } 

  imap_sasl_t imap_sasl;
  
  time_t imap_idle_timestamp;
  time_t imap_idle_maxdelay;

  mailprogress_function * imap_body_progress_fun;
  mailprogress_function * imap_items_progress_fun;
  void * imap_progress_context;
}

struct mailstream {
	size_t buffer_max_size;
	
	char * write_buffer;
	size_t write_buffer_len;
	
	char * read_buffer;
	size_t read_buffer_len;
	
	mailstream_low * low;
}

struct mailstream_low_driver {
	size_t function(mailstream_low *, void *, size_t) mailstream_read;
	size_t function(mailstream_low *, const void *, size_t) mailstream_write;
	int function(mailstream_low *) mailstream_close;
	int function(mailstream_low *) mailstream_get_fd;
	void function(mailstream_low *) mailstream_free;
	void function(mailstream_low *) mailstream_cancel;
}

struct mailstream_low {
	void * data;
	mailstream_low_driver * driver;
	int privacy;
	char * identifier;
}

/*
  mailimap_flag_list is a list of flags
  
  - list is a list of flags
*/

struct mailimap_flag_list {
  clist * fl_list; /* list of (struct mailimap_flag *), != NULL */
}

/*
  mailimap_capability_data is a list of capability

  - list is the list of capability
*/

struct mailimap_capability_data {
  clist * cap_list; /* list of (struct mailimap_capability *), != NULL */
}

/*
  set is a list of message sets

  - list is a list of message sets
*/
struct mailimap_set {
  clist * set_list; /* list of (struct mailimap_set_item *) */
}

/*
  mailimap_fetch_type is the description of the FETCH operation

  - type can be MAILIMAP_FETCH_TYPE_ALL, MAILIMAP_FETCH_TYPE_FULL,
    MAILIMAP_FETCH_TYPE_FAST, MAILIMAP_FETCH_TYPE_FETCH_ATT or
    MAILIMAP_FETCH_TYPE_FETCH_ATT_LIST

  - fetch_att is a fetch attribute if type is MAILIMAP_FETCH_TYPE_FETCH_ATT

  - fetch_att_list is a list of fetch attributes if type is
    MAILIMAP_FETCH_TYPE_FETCH_ATT_LIST
*/

struct mailimap_fetch_type {
  int ft_type;
  union ft_data_t{
    mailimap_fetch_att * ft_fetch_att;
    clist * ft_fetch_att_list; /* list of (struct mailimap_fetch_att *) */
  } 
  ft_data_t ft_data;
}
extern(C) mailimap_fetch_type *
mailimap_fetch_type_new(int ft_type,
    mailimap_fetch_att * ft_fetch_att,
    clist * ft_fetch_att_list);

extern(C) void mailimap_fetch_type_free(mailimap_fetch_type* fetch_type);

/*
  mailimap_search_key is the condition on the messages to return
  
  - type is the type of the condition

  - bcc is the text to search in the Bcc field when type is
    MAILIMAP_SEARCH_KEY_BCC, should be allocated with malloc()

  - before is a date when type is MAILIMAP_SEARCH_KEY_BEFORE

  - body is the text to search in the message when type is
    MAILIMAP_SEARCH_KEY_BODY, should be allocated with malloc()

  - cc is the text to search in the Cc field when type is
    MAILIMAP_SEARCH_KEY_CC, should be allocated with malloc()
  
  - from is the text to search in the From field when type is
    MAILIMAP_SEARCH_KEY_FROM, should be allocated with malloc()

  - keyword is the keyword flag name when type is MAILIMAP_SEARCH_KEY_KEYWORD,
    should be allocated with malloc()

  - on is a date when type is MAILIMAP_SEARCH_KEY_ON

  - since is a date when type is MAILIMAP_SEARCH_KEY_SINCE
  
  - subject is the text to search in the Subject field when type is
    MAILIMAP_SEARCH_KEY_SUBJECT, should be allocated with malloc()

  - text is the text to search in the text part of the message when
    type is MAILIMAP_SEARCH_KEY_TEXT, should be allocated with malloc()

  - to is the text to search in the To field when type is
    MAILIMAP_SEARCH_KEY_TO, should be allocated with malloc()

  - unkeyword is the keyword flag name when type is
    MAILIMAP_SEARCH_KEY_UNKEYWORD, should be allocated with malloc()

  - header_name is the header name when type is MAILIMAP_SEARCH_KEY_HEADER,
    should be allocated with malloc()

  - header_value is the text to search in the given header when type is
    MAILIMAP_SEARCH_KEY_HEADER, should be allocated with malloc()

  - larger is a size when type is MAILIMAP_SEARCH_KEY_LARGER

  - not is a condition when type is MAILIMAP_SEARCH_KEY_NOT

  - or1 is a condition when type is MAILIMAP_SEARCH_KEY_OR

  - or2 is a condition when type is MAILIMAP_SEARCH_KEY_OR
  
  - sentbefore is a date when type is MAILIMAP_SEARCH_KEY_SENTBEFORE

  - senton is a date when type is MAILIMAP_SEARCH_KEY_SENTON

  - sentsince is a date when type is MAILIMAP_SEARCH_KEY_SENTSINCE

  - smaller is a size when type is MAILIMAP_SEARCH_KEY_SMALLER

  - uid is a set of messages when type is MAILIMAP_SEARCH_KEY_UID

  - set is a set of messages when type is MAILIMAP_SEARCH_KEY_SET

  - multiple is a set of message when type is MAILIMAP_SEARCH_KEY_MULTIPLE
*/

struct mailimap_search_key {
  int sk_type;
  struct sk_or_t {
    mailimap_search_key * sk_or1;
    mailimap_search_key * sk_or2;
  }
  struct sk_header_t {
    char * sk_header_name;
    char * sk_header_value;
  } 
  union sk_data_t {
    char * sk_bcc;
    mailimap_date * sk_before;
    char * sk_body;
    char * sk_cc;
    char * sk_from;
    char * sk_keyword;
    mailimap_date * sk_on;
    mailimap_date * sk_since;
    char * sk_subject;
    char * sk_text;
    char * sk_to;
    char * sk_unkeyword;
	sk_or_t sk_or;
	sk_header_t sk_header;
    int sk_larger;
    mailimap_search_key * sk_not;
    mailimap_date * sk_sentbefore;
    mailimap_date * sk_senton;
    mailimap_date * sk_sentsince;
    int sk_smaller;
    mailimap_set * sk_uid;
    mailimap_set * sk_set;
    clist * sk_multiple; /* list of (struct mailimap_search_key *) */
  } 
  
  sk_data_t sk_data;
}

extern(C) mailimap_search_key *
mailimap_search_key_new(int sk_type,
    char * sk_bcc, mailimap_date * sk_before, char * sk_body,
    char * sk_cc, char * sk_from, char * sk_keyword,
    mailimap_date * sk_on, mailimap_date * sk_since,
    char * sk_subject, char * sk_text, char * sk_to,
    char * sk_unkeyword, char * sk_header_name,
    char * sk_header_value, int sk_larger,
    mailimap_search_key * sk_not,
    mailimap_search_key * sk_or1,
    mailimap_search_key * sk_or2,
    mailimap_date * sk_sentbefore,
    mailimap_date * sk_senton,
    mailimap_date * sk_sentsince,
    int sk_smaller, mailimap_set * sk_uid,
    mailimap_set * sk_set, clist * sk_multiple);

extern(C) void mailimap_search_key_free(mailimap_search_key * key);


/*
  mailimap_status_att_list is a list of mailbox STATUS request type

  - list is a list of mailbox STATUS request type
    (value of elements in the list can be MAILIMAP_STATUS_ATT_MESSAGES,
    MAILIMAP_STATUS_ATT_RECENT, MAILIMAP_STATUS_ATT_UIDNEXT,
    MAILIMAP_STATUS_ATT_UIDVALIDITY or MAILIMAP_STATUS_ATT_UNSEEN),
    each element should be allocated with malloc()
*/

struct mailimap_status_att_list {
  clist * att_list; /* list of (uint32_t *) */
};

extern(C) mailimap_status_att_list* mailimap_status_att_list_new(clist * att_list);

extern(C) void mailimap_status_att_list_free(mailimap_status_att_list * status_att_list);

struct mailimap_mailbox_data_status {
  char * st_mailbox;
  clist * st_info_list; /* list of (struct mailimap_status_info *) */
                            /* can be NULL */
}

extern(C) mailimap_mailbox_data_status *
mailimap_mailbox_data_status_new(char * st_mailbox,
    clist * st_info_list);

extern(C) void mailimap_mailbox_data_status_free(mailimap_mailbox_data_status * info);

/*
  mailimap_store_att_flags is the description of the STORE operation
  (change flags of a message)

  - sign can be 0 (set flag), +1 (add flag) or -1 (remove flag)

  - silent has a value of 1 if the flags are changed with no server
    response

  - flag_list is the list of flags to change
*/

struct mailimap_store_att_flags {
  int fl_sign;
  int fl_silent;
  mailimap_flag_list * fl_flag_list;
}

extern(C) mailimap_store_att_flags *
mailimap_store_att_flags_new(int fl_sign, int fl_silent,
			     mailimap_flag_list * fl_flag_list);

extern(C) void mailimap_store_att_flags_free(mailimap_store_att_flags *
    store_att_flags);

struct mailimap_date {
  int dt_day;
  int dt_month;
  int dt_year;
}

extern(C) mailimap_date *
mailimap_date_new(int dt_day, int dt_month, int dt_year);

extern(C) void mailimap_date_free(mailimap_date * date);



/* this is the condition of the SEARCH operation */

enum {
  MAILIMAP_SEARCH_KEY_ALL,        /* all messages */
  MAILIMAP_SEARCH_KEY_ANSWERED,   /* messages with the flag \Answered */
  MAILIMAP_SEARCH_KEY_BCC,        /* messages whose Bcc field contains the
                                     given string */
  MAILIMAP_SEARCH_KEY_BEFORE,     /* messages whose internal date is earlier
                                     than the specified date */
  MAILIMAP_SEARCH_KEY_BODY,       /* message that contains the given string
                                     (in header and text parts) */
  MAILIMAP_SEARCH_KEY_CC,         /* messages whose Cc field contains the
                                     given string */
  MAILIMAP_SEARCH_KEY_DELETED,    /* messages with the flag \Deleted */
  MAILIMAP_SEARCH_KEY_FLAGGED,    /* messages with the flag \Flagged */ 
  MAILIMAP_SEARCH_KEY_FROM,       /* messages whose From field contains the
                                     given string */
  MAILIMAP_SEARCH_KEY_KEYWORD,    /* messages with the flag keyword set */
  MAILIMAP_SEARCH_KEY_NEW,        /* messages with the flag \Recent and not
                                     the \Seen flag */
  MAILIMAP_SEARCH_KEY_OLD,        /* messages that do not have the
                                     \Recent flag set */
  MAILIMAP_SEARCH_KEY_ON,         /* messages whose internal date is the
                                     specified date */
  MAILIMAP_SEARCH_KEY_RECENT,     /* messages with the flag \Recent */
  MAILIMAP_SEARCH_KEY_SEEN,       /* messages with the flag \Seen */
  MAILIMAP_SEARCH_KEY_SINCE,      /* messages whose internal date is later
                                     than specified date */
  MAILIMAP_SEARCH_KEY_SUBJECT,    /* messages whose Subject field contains the
                                     given string */
  MAILIMAP_SEARCH_KEY_TEXT,       /* messages whose text part contains the
                                     given string */
  MAILIMAP_SEARCH_KEY_TO,         /* messages whose To field contains the
                                     given string */
  MAILIMAP_SEARCH_KEY_UNANSWERED, /* messages with no flag \Answered */
  MAILIMAP_SEARCH_KEY_UNDELETED,  /* messages with no flag \Deleted */
  MAILIMAP_SEARCH_KEY_UNFLAGGED,  /* messages with no flag \Flagged */
  MAILIMAP_SEARCH_KEY_UNKEYWORD,  /* messages with no flag keyword */ 
  MAILIMAP_SEARCH_KEY_UNSEEN,     /* messages with no flag \Seen */
  MAILIMAP_SEARCH_KEY_DRAFT,      /* messages with no flag \Draft */
  MAILIMAP_SEARCH_KEY_HEADER,     /* messages whose given field 
                                     contains the given string */
  MAILIMAP_SEARCH_KEY_LARGER,     /* messages whose size is larger then
                                     the given size */
  MAILIMAP_SEARCH_KEY_NOT,        /* not operation of the condition */
  MAILIMAP_SEARCH_KEY_OR,         /* or operation between two conditions */
  MAILIMAP_SEARCH_KEY_SENTBEFORE, /* messages whose date given in Date header
                                     is earlier than the specified date */
  MAILIMAP_SEARCH_KEY_SENTON,     /* messages whose date given in Date header
                                     is the specified date */
  MAILIMAP_SEARCH_KEY_SENTSINCE,  /* messages whose date given in Date header
                                     is later than specified date */
  MAILIMAP_SEARCH_KEY_SMALLER,    /* messages whose size is smaller than
                                     the given size */
  MAILIMAP_SEARCH_KEY_UID,        /* messages whose unique identifiers are
                                     in the given range */
  MAILIMAP_SEARCH_KEY_UNDRAFT,    /* messages with no flag \Draft */
  MAILIMAP_SEARCH_KEY_SET,        /* messages whose number (or unique
                                     identifiers in case of UID SEARCH) are
                                     in the given range */
  MAILIMAP_SEARCH_KEY_MULTIPLE    /* the boolean operator between the
                                     conditions is AND */
}

/*
  mailimap_connection_info is the information about the connection
  
  - capability is the list of capability of the IMAP server
*/

struct mailimap_connection_info {
  mailimap_capability_data * imap_capability;
}

extern(C) mailimap_connection_info * mailimap_connection_info_new();

extern(C) void mailimap_connection_info_free(mailimap_connection_info * conn_info);

/*
  mailimap_fetch_att is the description of the fetch attribute

  - type is the type of fetch attribute, the value can be
    MAILIMAP_FETCH_ATT_ENVELOPE, MAILIMAP_FETCH_ATT_FLAGS,
    MAILIMAP_FETCH_ATT_INTERNALDATE, MAILIMAP_FETCH_ATT_RFC822,
    MAILIMAP_FETCH_ATT_RFC822_HEADER, MAILIMAP_FETCH_ATT_RFC822_SIZE,
    MAILIMAP_FETCH_ATT_RFC822_TEXT, MAILIMAP_FETCH_ATT_BODY,
    MAILIMAP_FETCH_ATT_BODYSTRUCTURE, MAILIMAP_FETCH_ATT_UID,
    MAILIMAP_FETCH_ATT_BODY_SECTION or MAILIMAP_FETCH_ATT_BODY_PEEK_SECTION

  - section is the location of the part to fetch if type is
    MAILIMAP_FETCH_ATT_BODY_SECTION or MAILIMAP_FETCH_ATT_BODY_PEEK_SECTION

  - offset is the first byte to fetch in the given part

  - size is the maximum size of the part to fetch
*/

struct mailimap_fetch_att {
  int att_type;
  mailimap_section * att_section;
  int att_offset;
  int att_size;
}
extern(C) mailimap_fetch_att *
mailimap_fetch_att_new(int att_type, mailimap_section * att_section,
		       int att_offset, int att_size);

extern(C) void mailimap_fetch_att_free(mailimap_fetch_att * fetch_att);


/* this is the type of a FETCH operation */

enum {
  MAILIMAP_FETCH_TYPE_ALL,            /* equivalent to (FLAGS INTERNALDATE
                                         RFC822.SIZE ENVELOPE) */
  MAILIMAP_FETCH_TYPE_FULL,           /* equivalent to (FLAGS INTERNALDATE
                                         RFC822.SIZE ENVELOPE BODY) */
  MAILIMAP_FETCH_TYPE_FAST,           /* equivalent to (FLAGS INTERNALDATE
                                         RFC822.SIZE) */
  MAILIMAP_FETCH_TYPE_FETCH_ATT,      /* when there is only of fetch
                                         attribute */
  MAILIMAP_FETCH_TYPE_FETCH_ATT_LIST  /* when there is a list of fetch
                                         attributes */
}

struct mailimap_response {
  clist * rsp_cont_req_or_resp_data_list;
  /* list of (struct mailiap_cont_req_or_resp_data *) */
                                   /* can be NULL */
  mailimap_response_done * rsp_resp_done; /* != NULL */
}

extern(C) mailimap_response *
mailimap_response_new(clist * rsp_cont_req_or_resp_data_list,
    mailimap_response_done * rsp_resp_done);

extern(C) void mailimap_response_free(mailimap_response * resp);

enum {
  MAILIMAP_RESP_DONE_TYPE_ERROR,  /* on parse error */
  MAILIMAP_RESP_DONE_TYPE_TAGGED, /* tagged response */
  MAILIMAP_RESP_DONE_TYPE_FATAL   /* fatal error response */
}

/*
  mailimap_response_done is an ending response

  - type is the type of the ending response

  - tagged is a tagged response

  - fatal is a fatal error response
*/

struct mailimap_response_done {
  int rsp_type;
  union rsp_data_t {
    mailimap_response_tagged * rsp_tagged; /* can be NULL */
    mailimap_response_fatal * rsp_fatal;   /* can be NULL */
  } 

  rsp_data_t rsp_data;
}

extern(C) mailimap_response_done *
mailimap_response_done_new(int rsp_type,
    mailimap_response_tagged * rsp_tagged,
    mailimap_response_fatal * rsp_fatal);

extern(C) void mailimap_response_done_free(mailimap_response_done *
				 resp_done);

/*
  mailimap_resp_cond_state is a condition state reponse
  
  - type is the type of the condition state response

  - text is a text response
*/

struct mailimap_resp_cond_state {
  int rsp_type;
  mailimap_resp_text * rsp_text; /* can be NULL */
};

extern(C) mailimap_resp_cond_state *
mailimap_resp_cond_state_new(int rsp_type,
    mailimap_resp_text * rsp_text);

extern(C) void mailimap_resp_cond_state_free(mailimap_resp_cond_state * cond_state);

struct mailimap_selection_info {
  clist * sel_perm_flags; /* list of (struct flag_perm *) */
  int sel_perm;
  int sel_uidnext;
  int sel_uidvalidity;
  int sel_first_unseen;
  mailimap_flag_list * sel_flags;
  int sel_exists;
  int sel_recent;
  int sel_unseen;
};

extern(C) mailimap_selection_info *
mailimap_selection_info_new();

extern(C) void mailimap_selection_info_free(mailimap_selection_info * sel_info);

/*
  mailimap_response_info is the other information returned in the 
  response for a command

  - alert is the human readable text returned with ALERT response

  - parse is the human readable text returned with PARSE response

  - badcharset is a list of charset returned with a BADCHARSET response

  - trycreate is set to 1 if a trycreate response was returned
  
  - mailbox_list is a list of mailboxes
  
  - mailbox_lsub is a list of subscribed mailboxes

  - search_result is a list of message numbers or unique identifiers

  - status is a STATUS response

  - expunged is a list of message numbers

  - fetch_list is a list of fetch response
*/

struct mailimap_response_info {
  char * rsp_alert;
  char * rsp_parse;
  clist * rsp_badcharset; /* list of (char *) */
  int rsp_trycreate;
  clist * rsp_mailbox_list; /* list of (struct mailimap_mailbox_list *) */
  clist * rsp_mailbox_lsub; /* list of (struct mailimap_mailbox_list *) */
  clist * rsp_search_result; /* list of (uint32_t *) */
  mailimap_mailbox_data_status * rsp_status;
  clist * rsp_expunged; /* list of (uint32_t 32 *) */
  clist * rsp_fetch_list; /* list of (struct mailimap_msg_att *) */
  clist * rsp_extension_list; /* list of (struct mailimap_extension_data *) */
  char * rsp_atom;
  char * rsp_value;
};

extern(C) mailimap_response_info *
mailimap_response_info_new();

extern(C) void
mailimap_response_info_free(mailimap_response_info * resp_info);

/*
  mailimap_response_fatal is a fatal error response

  - bye is a BYE response text
*/

struct mailimap_response_fatal {
  mailimap_resp_cond_bye * rsp_bye; /* != NULL */
}

extern(C) mailimap_response_fatal *
mailimap_response_fatal_new(mailimap_resp_cond_bye * rsp_bye);

extern(C) void mailimap_response_fatal_free(mailimap_response_fatal * resp_fatal);


/*
  mailimap_response_tagged is a tagged response

  - tag is the sent tag, should be allocated with malloc()

  - cond_state is a condition state response
*/

struct mailimap_response_tagged {
  char * rsp_tag; /* != NULL */
  mailimap_resp_cond_state * rsp_cond_state; /* != NULL */
};

extern(C) mailimap_response_tagged *
mailimap_response_tagged_new(char * rsp_tag,
    mailimap_resp_cond_state * rsp_cond_state);

extern(C) void mailimap_response_tagged_free(mailimap_response_tagged * tagged);

/* this is the type of an authentication condition response */

enum {
  MAILIMAP_RESP_COND_AUTH_ERROR,   /* on parse error */
  MAILIMAP_RESP_COND_AUTH_OK,      /* authentication is needed */
  MAILIMAP_RESP_COND_AUTH_PREAUTH  /* authentication is not needed */
}

/*
  mailimap_resp_cond_auth is an authentication condition response

  - type is the type of the authentication condition response,
    the value can be MAILIMAP_RESP_COND_AUTH_OK or
    MAILIMAP_RESP_COND_AUTH_PREAUTH

  - text is a text response
*/

struct mailimap_resp_cond_auth {
  int rsp_type;
  mailimap_resp_text * rsp_text; /* != NULL */
}

extern(C) mailimap_resp_cond_auth *
mailimap_resp_cond_auth_new(int rsp_type,
    mailimap_resp_text * rsp_text);

extern(C) void mailimap_resp_cond_auth_free(mailimap_resp_cond_auth * cond_auth);

/*
  mailimap_resp_cond_bye is a BYE response

  - text is a text response
*/

struct mailimap_resp_cond_bye {
  mailimap_resp_text * rsp_text; /* != NULL */
}

extern(C) mailimap_resp_cond_bye *
mailimap_resp_cond_bye_new(mailimap_resp_text * rsp_text);

extern(C) void mailimap_resp_cond_bye_free(mailimap_resp_cond_bye * cond_bye);

/* this is the type of a condition state response */

enum {
  MAILIMAP_RESP_COND_STATE_OK,
  MAILIMAP_RESP_COND_STATE_NO,
  MAILIMAP_RESP_COND_STATE_BAD
}

struct mailimap_resp_text {
  mailimap_resp_text_code * rsp_code; /* can be NULL */
  char * rsp_text; /* can be NULL */
}

extern(C) mailimap_resp_text *
mailimap_resp_text_new(mailimap_resp_text_code * resp_code,
		       char * rsp_text);

extern(C) void mailimap_resp_text_free(mailimap_resp_text * resp_text);

/* this is the type of the response code */

enum {
  MAILIMAP_RESP_TEXT_CODE_ALERT,           /* ALERT response */
  MAILIMAP_RESP_TEXT_CODE_BADCHARSET,      /* BADCHARSET response */
  MAILIMAP_RESP_TEXT_CODE_CAPABILITY_DATA, /* CAPABILITY response */
  MAILIMAP_RESP_TEXT_CODE_PARSE,           /* PARSE response */
  MAILIMAP_RESP_TEXT_CODE_PERMANENTFLAGS,  /* PERMANENTFLAGS response */
  MAILIMAP_RESP_TEXT_CODE_READ_ONLY,       /* READONLY response */
  MAILIMAP_RESP_TEXT_CODE_READ_WRITE,      /* READWRITE response */
  MAILIMAP_RESP_TEXT_CODE_TRY_CREATE,      /* TRYCREATE response */
  MAILIMAP_RESP_TEXT_CODE_UIDNEXT,         /* UIDNEXT response */
  MAILIMAP_RESP_TEXT_CODE_UIDVALIDITY,     /* UIDVALIDITY response */
  MAILIMAP_RESP_TEXT_CODE_UNSEEN,          /* UNSEEN response */
  MAILIMAP_RESP_TEXT_CODE_OTHER,           /* other type of response */
  MAILIMAP_RESP_TEXT_CODE_EXTENSION        /* extension response */
}

/*
  mailimap_resp_text_code is a response code
  
  - type is the type of the response code, the value can be
    MAILIMAP_RESP_TEXT_CODE_ALERT, MAILIMAP_RESP_TEXT_CODE_BADCHARSET,
    MAILIMAP_RESP_TEXT_CODE_CAPABILITY_DATA, MAILIMAP_RESP_TEXT_CODE_PARSE,
    MAILIMAP_RESP_TEXT_CODE_PERMANENTFLAGS, MAILIMAP_RESP_TEXT_CODE_READ_ONLY,
    MAILIMAP_RESP_TEXT_CODE_READ_WRITE, MAILIMAP_RESP_TEXT_CODE_TRY_CREATE,
    MAILIMAP_RESP_TEXT_CODE_UIDNEXT, MAILIMAP_RESP_TEXT_CODE_UIDVALIDITY,
    MAILIMAP_RESP_TEXT_CODE_UNSEEN or MAILIMAP_RESP_TEXT_CODE_OTHER
    
  - badcharset is a list of charsets if type
    is MAILIMAP_RESP_TEXT_CODE_BADCHARSET, each element should be
    allocated with malloc()

  - cap_data is a list of capabilities

  - perm_flags is a list of flags, this is the flags that can be changed
    permanently on the messages of the mailbox.

  - uidnext is the next unique identifier of a message
  
  - uidvalidity is the unique identifier validity value

  - first_unseen is the number of the first message without the \Seen flag
  
  - atom is a keyword for an extension response code, should be allocated
    with malloc()

  - atom_value is the data related with the extension response code,
    should be allocated with malloc()
*/

struct mailimap_resp_text_code {
  int rc_type;
  struct rc_atom_t {
    char * atom_name;  /* can be NULL */
    char * atom_value; /* can be NULL */
  }

  union rc_data_t {
    clist * rc_badcharset; /* list of astring (char *) */
    /* can be NULL */
    mailimap_capability_data * rc_cap_data; /* != NULL */
    clist * rc_perm_flags; /* list of (struct mailimap_flag_perm *) */
    /* can be NULL */
    int rc_uidnext;
    int rc_uidvalidity;
    int rc_first_unseen;
    mailimap_extension_data * rc_ext_data; /* can be NULL */
	rc_atom_t rc_atom;
  } 
  rc_data_t rc_data;
}

extern(C) mailimap_resp_text_code *
mailimap_resp_text_code_new(int rc_type, clist * rc_badcharset,
    mailimap_capability_data * rc_cap_data,
    clist * rc_perm_flags,
    int rc_uidnext, int rc_uidvalidity,
    int rc_first_unseen, char * rc_atom, char * rc_atom_value,
    mailimap_extension_data * rc_ext_data);

extern(C) void mailimap_resp_text_code_free(mailimap_resp_text_code * resp_text_code);

void check_error(int r, char * msg) {
	if (r == MAILIMAP_NO_ERROR)
		return;
	if(r == MAILIMAP_NO_ERROR_AUTHENTICATED)
		return;
	if(r == MAILIMAP_NO_ERROR_NON_AUTHENTICATED)
		return;

	throw new Exception(to!string(msg));
}

char* get_msg_att_msg_content(mailimap_msg_att* msg_att, size_t * p_msg_size) {
	clistiter* cur;

	/* iterate on each result of one given message */
	for(cur = clist_begin(msg_att.att_list) ; cur !is null ; cur = clist_next(cur)) {
		mailimap_msg_att_item* item;

		item = cast(mailimap_msg_att_item*)clist_content(cur);
		if(item.att_type != MAILIMAP_MSG_ATT_ITEM_STATIC) {
			continue;
		}

    	if(item.att_data.att_static.att_type != MAILIMAP_MSG_ATT_BODY_SECTION) {
			continue;
    	}

		*p_msg_size = item.att_data.att_static.att_data.att_body_section.sec_length;
		return item.att_data.att_static.att_data.att_body_section.sec_body_part;
	}

	return null;
}

char* get_msg_content(clist * fetch_result, size_t * p_msg_size) {
	clistiter * cur;

  /* for each message (there will be probably only on message) */
	for(cur = clist_begin(fetch_result) ; cur !is null ; cur = clist_next(cur)) {
		mailimap_msg_att * msg_att;
		size_t msg_size;
		char * msg_content;

		msg_att = cast(mailimap_msg_att*)clist_content(cur);
		msg_content = get_msg_att_msg_content(msg_att, &msg_size);
		if (msg_content is null) {
			continue;
		}

		*p_msg_size = msg_size;
		return msg_content;
	}

	return null;
}

void fetch_msg(mailimap* imap, int uid) {
	mailimap_set * set;
	mailimap_section * section;
	//char[512] filename;
	size_t msg_len;
	char * msg_content;
	File f;
	mailimap_fetch_type * fetch_type;
	mailimap_fetch_att * fetch_att;
	int r;
	clist* fetch_result;
	//stat stat_info;

	//snprintf(filename, sizeof(filename), "download/%u.eml", cast(uint)uid);
	Appender!string filename;
	formattedWrite(filename, "download/%u.eml", cast(uint)uid);
	/*r = stat(filename, &stat_info);
	if (r == 0) {
		// already cached
		printf("%u is already fetched\n", cast(uint) uid);
		return;
	}*/

	set = mailimap_set_new_single(uid);
	fetch_type = mailimap_fetch_type_new_fetch_att_list_empty();
	section = mailimap_section_new(NULL);
	fetch_att = mailimap_fetch_att_new_body_peek_section(section);
	mailimap_fetch_type_new_fetch_att_list_add(fetch_type, fetch_att);

	r = mailimap_uid_fetch(imap, set, fetch_type, &fetch_result);
	check_error(r, "could not fetch");
	printf("fetch %u\n", cast(uint) uid);

	msg_content = get_msg_content(fetch_result, &msg_len);
	if (msg_content is null) {
		fprintf(stderr, "no content\n");
		mailimap_fetch_list_free(fetch_result);
		return;
	}

	f = fopen(filename, "w");
	if (f is null) {
		fprintf(stderr, "could not write\n");
		mailimap_fetch_list_free(fetch_result);
		return;
	}

	fwrite(msg_content, 1, msg_len, f);
	fclose(f);

	writefln("%u has been fetched\n", cast(uint) uid);

	mailimap_fetch_list_free(fetch_result);
}
