module lietpand.etpan;

import core.stdc.time;
import std.conv;
import std.format;
import std.array;
import std.file;
import std.stdio;

immutable PATH_MAX = 4096; //TODO get header info

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

//(((lst).first==(lst).last) && ((lst).last==NULL))
bool clist_isempty(clist* lst) {
	return lst.first == lst.last && lst.last is null;
}

//clist_count(lst)               ((lst).count)
int clist_count(clist* lst) {
	return lst.count;
}

//clist_begin(lst)               ((lst).first)
clistcell* clist_begin(clist* lst) {
	return lst.first;
}

//clist_end(lst)                 ((lst).last)
clistcell* clist_end(clist* lst) {
	return lst.last;
}

//clist_next(iter)               (iter ? (iter).next : NULL)
clistiter* clist_next(clistiter* iter) {
	return iter ? iter.next : null;
}

//clist_previous(iter)           (iter ? (iter).previous : NULL)
clistiter* clist_previous(clistiter* iter) {
	return iter ? iter.previous : null;
}

//clist_content(iter)            (iter ? (iter).data : NULL)
void* clist_content(clistiter* iter) {
	return iter ? iter.data : null;
}

//clist_prepend(lst, data)  (clist_insert_before(lst, (lst).first, data))
int clist_prepend(clist* lst, void* data) {
	return clist_insert_before(lst, lst.first, data);
}

//clist_append(lst, data)   (clist_insert_after(lst, (lst).last, data))
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
  clist * sec_id; /* list of nz-number (int *) */
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
   @param result   The result is a clist of (int *) and will be
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
   @param result   The result is a clist of (int *) and will be
   stored in (* result).
   
   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_uid_search(mailimap * session, const char * charset,
    mailimap_search_key * key, clist ** result);

/*
   mailimap_search_result_free()

   This function will free the result of the a search.

   @param search_result   This is a clist of (int *) returned
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
  clist * att_list; /* list of (int *) */
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
  clist * rsp_search_result; /* list of (int *) */
  mailimap_mailbox_data_status * rsp_status;
  clist * rsp_expunged; /* list of (int 32 *) */
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

/*
  mailimap_acl_setacl()

  This will set access for an identifier on the mailbox specified.

  @param session      the IMAP session
  @param mailbox      the mailbox to modify
  @param identifier   the identifier to set access-rights for
  @param mod_rights   the modification to make to the rights

  @return the return code is one of MAILIMAP_ERROR_XXX or
    MAILIMAP_NO_ERROR codes

*/
extern(C) int mailimap_acl_setacl(mailimap * session,
    const char * mailbox,
    const char * identifier,
    const char * mod_rights);

/*
  mailimap_acl_deleteacl()

  This will remove the acl on the mailbox for the identifier specified.

  @param session      the IMAP session
  @param mailbox      the mailbox to modify
  @param identifier   the identifier to remove acl for

  @return the return code is one of MAILIMAP_ERROR_XXX or
    MAILIMAP_NO_ERROR codes

*/
extern(C) int mailimap_acl_deleteacl(mailimap * session,
    const char * mailbox,
    const char * identifier);

/*
  mailimap_acl_getacl()

  This will get a list of acls for the mailbox

  @param session  the IMAP session
  @param mailbox  the mailbox to get the acls for
  @param result   this will store a clist of (struct mailimap_acl_acl_data *)
      in (* result)

  @return the return code is one of MAILIMAP_ERROR_XXX or
    MAILIMAP_NO_ERROR codes

*/
extern(C) int mailimap_acl_getacl(mailimap * session,
    const char * mailbox,
    clist ** result);

/*
  mailimap_acl_listrights()

  The LISTRIGHTS command takes a mailbox name and an identifier and
  returns information about what rights can be granted to the
  identifier in the ACL for the mailbox.

  @param session    the IMAP session
  @param mailbox    the mailbox to get the acls for
  @param identifier the identifier to query the acls for
  @param result     this will store a (struct mailimap_acl_listrights_data *)

  @return the return code is one of MAILIMAP_ERROR_XXX or
    MAILIMAP_NO_ERROR codes

*/
extern(C) int mailimap_acl_listrights(mailimap * session,
    const char * mailbox,
    const char * identifier,
    mailimap_acl_listrights_data ** result);

/*
  mailimap_acl_myrights()

  This will list the rights for the querying user on the mailbox

  @param session    the IMAP session
  @param mailbox    the mailbox to get the acls for
  @param result     this will store a (struct mailimap_acl_myrights_data *)

  @return the return code is one of MAILIMAP_ERROR_XXX or
    MAILIMAP_NO_ERROR codes

*/
extern(C) int mailimap_acl_myrights(mailimap * session,
    const char * mailbox,
    mailimap_acl_myrights_data ** result);
extern(C) int mailimap_has_acl(mailimap * session);

/*
   ACL grammar
   see [rfc4314] for further information

   LOWER-ALPHA     =  %x61-7A   ;; a-z

   acl-data        = "ACL" SP mailbox *(SP identifier SP
                       rights)

   capability      =/ rights-capa
                       ;;capability is defined in [IMAP4]

   command-auth    =/ setacl / deleteacl / getacl /
                       listrights / myrights
                       ;;command-auth is defined in [IMAP4]

   deleteacl       = "DELETEACL" SP mailbox SP identifier

   getacl          = "GETACL" SP mailbox

   identifier      = astring

   listrights      = "LISTRIGHTS" SP mailbox SP identifier

   listrights-data = "LISTRIGHTS" SP mailbox SP identifier
                           SP rights *(SP rights)

   mailbox-data    =/ acl-data / listrights-data / myrights-data
                       ;;mailbox-data is defined in [IMAP4]

   mod-rights      = astring
                       ;; +rights to add, -rights to remove
                       ;; rights to replace

   myrights        = "MYRIGHTS" SP mailbox

   myrights-data   = "MYRIGHTS" SP mailbox SP rights

   new-rights      = 1*LOWER-ALPHA
                       ;; MUST include "t", "e", "x", and "k".
                       ;; MUST NOT include standard rights listed
                       ;; in section 2.2

   rights          = astring
                       ;; only lowercase ASCII letters and digits
                       ;; are allowed.

   rights-capa     = "RIGHTS=" new-rights
                       ;; RIGHTS=... capability

   setacl          = "SETACL" SP mailbox SP identifier
                       SP mod-rights
*/

/*
  only need to recognize types that can be "embedded" into main
  IMAPrev1 types.
*/
enum {
  MAILIMAP_ACL_TYPE_ACL_DATA,                   /* child of mailbox-data  */
  MAILIMAP_ACL_TYPE_LISTRIGHTS_DATA,            /* child of mailbox-data  */
  MAILIMAP_ACL_TYPE_MYRIGHTS_DATA               /* child of mailbox-data  */
}
extern(C) void mailimap_acl_identifier_free(char * identifier);
extern(C) void mailimap_acl_rights_free(char * rights);

struct mailimap_acl_identifier_rights {
  char * identifer;
  char * rights;
}

extern(C) mailimap_acl_identifier_rights *
mailimap_acl_identifier_rights_new(char * identifier, char * rights);
extern(C) void mailimap_acl_identifier_rights_free(
        mailimap_acl_identifier_rights * id_rights);

struct mailimap_acl_acl_data {
  char * mailbox;
  clist * idrights_list;
  /* list of (struct mailimap_acl_identifier_rights *) */
}

extern(C) mailimap_acl_acl_data *
mailimap_acl_acl_data_new(char * mailbox, clist * idrights_list);

extern(C) void mailimap_acl_acl_data_free(mailimap_acl_acl_data * acl_data);

struct mailimap_acl_listrights_data {
  char * mailbox;
  char * identifier;
  clist * rights_list; /* list of (char *) */
}

extern(C) mailimap_acl_listrights_data *
mailimap_acl_listrights_data_new(char * mailbox,
        char * identifier, clist * rights_list);

extern(C) void mailimap_acl_listrights_data_free(mailimap_acl_listrights_data * listrights_data);

struct mailimap_acl_myrights_data {
  char * mailbox;
  char * rights;
}

extern(C) mailimap_acl_myrights_data *
mailimap_acl_myrights_data_new(char * mailbox, char * rights);
extern(C) void mailimap_acl_myrights_data_free(mailimap_acl_myrights_data * myrights_data);

extern(C) void
mailimap_acl_free(mailimap_extension_data * ext_data);

extern(C) mailimap_extension_api mailimap_extension_annotatemore;

/*
  mailimap_annotatemore_getannotation()

  This function will get annotations from given mailboxes or the server.

  @param session the IMAP session
  @param list_mb mailbox name with possible wildcard,
                 empty string implies server annotation
  @param entries entry specifier with possible wildcards
  @param attribs attribute specifier with possible wildcards
  @param result  This will store a clist of (struct mailimap_annotate_data *)
      in (* result)

  @return the return code is one of MAILIMAP_ERROR_XXX or
    MAILIMAP_NO_ERROR codes
  
*/
extern(C) int mailimap_annotatemore_getannotation(mailimap * session,
    const char * list_mb,
    mailimap_annotatemore_entry_match_list * entries,
    mailimap_annotatemore_attrib_match_list * attribs,
    clist ** result);

/*
  mailimap_annotatemore_setannotation()

  This function will set annotations on given mailboxes or the server.

  @param session  the IMAP session
  @param list_mb  mailbox name with possible wildcard,
                  empty string implies server annotation
  @param en_att   a list of entries/attributes to set
  @param result   if return is MAILIMAP_ERROR_EXTENSION result
                  is MAILIMAP_ANNOTATEMORE_RESP_TEXT_CODE_TOOBIG or
                  MAILIMAP_ANNOTATEMORE_RESP_TEXT_CODE_TOOMANY for
                  extra information about the error.

  @return the return code is one of MAILIMAP_ERROR_XXX or
    MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_annotatemore_setannotation(mailimap * session,
    const char * list_mb,
    mailimap_annotatemore_entry_att_list * en_att,
    int * result);
extern(C) int mailimap_has_annotatemore(mailimap * session);

struct carray_s {
  void ** array;
  uint len;
  uint max;
}

alias carray_s carray;

/* Creates a new array of pointers, with initsize preallocated cells */
extern(C) carray *   carray_new(uint initsize);

/* Adds the pointer to data in the array.
   Returns the index of the pointer in the array or -1 on error */
extern(C) int       carray_add(carray * array, void * data, uint * indx);
extern(C) int carray_set_size(carray * array, uint new_size);

/* Removes the cell at this index position. Returns TRUE on success.
   Order of elements in the array IS changed. */
extern(C) int       carray_delete(carray * array, uint indx);

/* Removes the cell at this index position. Returns TRUE on success.
   Order of elements in the array IS not changed. */
extern(C) int       carray_delete_slow(carray * array, uint indx);

/* remove without decreasing the size of the array */
extern(C) int carray_delete_fast(carray * array, uint indx);

/* Some of the following routines can be implemented as macros to
   be faster. If you don't want it, define NO_MACROS */

/* Returns the array itself */
extern(C) void **   carray_data(carray *);

/* Returns the number of elements in the array */
extern(C) uint carray_count(carray *);

/* Returns the contents of one cell */
extern(C) void *    carray_get(carray * array, uint indx);

/* Sets the contents of one cell */
extern(C) void      carray_set(carray * array, uint indx, void * value);

void ** carray_data(carray * array)
{
  return array.array;
}

uint carray_count(carray * array)
{
  return array.len;
}

void * carray_get(carray * array, uint indx)
{
  return array.array[indx];
}

void carray_set(carray * array, uint indx, void * value)
{
  array.array[indx] = value;
}

extern(C) void carray_free(carray * array);

/*
   ANNOTATEMORE grammar
   see [draft-daboo-imap-annotatemore-07] for further information

   annotate-data     = "ANNOTATION" SP mailbox SP entry-list
                       ; empty string for mailbox implies
                       ; server annotation.

   att-value         = attrib SP value

   attrib            = string
                       ; dot-separated attribute name
                       ; MUST NOT contain "*" or "%"
   attrib-match      = string
                       ; dot-separated attribute name
                       ; MAY contain "*" or "%" for use as wildcards

   attribs           = attrib-match / "(" attrib-match *(SP attrib-match) ")"
                       ; attribute specifiers that can include wildcards

   command-auth      /= setannotation / getannotation
                       ; adds to original IMAP command

   entries           = entry-match / "(" entry-match *(SP entry-match) ")"
                       ; entry specifiers that can include wildcards

   entry             = string
                       ; slash-separated path to entry
                       ; MUST NOT contain "*" or "%"

   entry-att         = entry SP "(" att-value *(SP att-value) ")"

   entry-list        = entry-att *(SP entry-att) /
                       "(" entry *(SP entry) ")"
                       ; entry attribute-value pairs list for
                       ; GETANNOTATION response, or
                       ; parenthesised entry list for unsolicited
                       ; notification of annotation changes

   entry-match       = string
                       ; slash-separated path to entry
                       ; MAY contain "*" or "%" for use as wildcards

   getannotation     = "GETANNOTATION" SP list-mailbox SP entries SP attribs
                       ; empty string for list-mailbox implies
                       ; server annotation.

   response-data     /= "*" SP annotate-data CRLF
                       ; adds to original IMAP data responses

   resp-text-code    =/ "ANNOTATEMORE" SP "TOOBIG" /
                        "ANNOTATEMORE" SP "TOOMANY"
                       ; new response codes for SETANNOTATION failures

   setannotation     = "SETANNOTATION" SP list-mailbox SP setentryatt
                       ; empty string for list-mailbox implies
                       ; server annotation.

   setentryatt       = entry-att / "(" entry-att *(SP entry-att) ")"

   value             = nstring
*/

/*
  only need to recognize types that can be "embedded" into main
  IMAPrev1 types.
*/
enum {
  MAILIMAP_ANNOTATEMORE_TYPE_ANNOTATE_DATA,          /* child of response-data   */
  MAILIMAP_ANNOTATEMORE_TYPE_RESP_TEXT_CODE          /* child of resp-text-code  */
}

/*
  error codes for annotatemore.
*/
enum {
  MAILIMAP_ANNOTATEMORE_RESP_TEXT_CODE_UNSPECIFIED, /* unspecified response   */
  MAILIMAP_ANNOTATEMORE_RESP_TEXT_CODE_TOOBIG,      /* annotation too big     */
  MAILIMAP_ANNOTATEMORE_RESP_TEXT_CODE_TOOMANY      /* too many annotations   */
}

extern(C) void mailimap_annotatemore_attrib_free(char * attrib);

extern(C) void mailimap_annotatemore_value_free(char * value);

extern(C) void mailimap_annotatemore_entry_free(char * entry);

struct mailimap_annotatemore_att_value  {
  char * attrib;
  char * value;
}
extern(C) mailimap_annotatemore_att_value *
mailimap_annotatemore_att_value_new(char * attrib, char * value);

extern(C) void mailimap_annotatemore_att_value_free(
        mailimap_annotatemore_att_value * att_value);

struct mailimap_annotatemore_entry_att {
  char * entry;
  clist * att_value_list;
  /* list of (struct mailimap_annotatemore_att_value *) */
}
extern(C) mailimap_annotatemore_entry_att *
mailimap_annotatemore_entry_att_new(char * entry, clist * list);
extern(C) void mailimap_annotatemore_entry_att_free(
        mailimap_annotatemore_entry_att * en_att);
extern(C) mailimap_annotatemore_entry_att *
mailimap_annotatemore_entry_att_new_empty(char * entry);
extern(C) int mailimap_annotatemore_entry_att_add(
        mailimap_annotatemore_entry_att * en_att,
        mailimap_annotatemore_att_value * at_value);

enum {
  MAILIMAP_ANNOTATEMORE_ENTRY_LIST_TYPE_ERROR,          /* error condition */
  MAILIMAP_ANNOTATEMORE_ENTRY_LIST_TYPE_ENTRY_ATT_LIST, /* entry-att-list */
  MAILIMAP_ANNOTATEMORE_ENTRY_LIST_TYPE_ENTRY_LIST      /* entry-list */
}

struct mailimap_annotatemore_entry_list {
  int en_list_type;
  clist * en_list_data;
  /* either a list of (struct annotatemore_entry_att *)
     or a list of (char *) */
}

extern(C) mailimap_annotatemore_entry_list* 
mailimap_annotatemore_entry_list_new(int type, clist * en_att_list, clist * en_list);

void mailimap_annotatemore_entry_list_free(
        mailimap_annotatemore_entry_list * en_list);

struct mailimap_annotatemore_annotate_data {
  char * mailbox;
  mailimap_annotatemore_entry_list * entry_list;
}

extern(C) mailimap_annotatemore_annotate_data* 
mailimap_annotatemore_annotate_data_new(char * mb, 
        mailimap_annotatemore_entry_list * en_list);
extern(C) void mailimap_annotatemore_annotate_data_free(
        mailimap_annotatemore_annotate_data * an_data);

struct mailimap_annotatemore_entry_match_list {
  clist * entry_match_list; /* list of (char *) */
}
extern(C) mailimap_annotatemore_entry_match_list *
mailimap_annotatemore_entry_match_list_new(clist * en_list);
extern(C) void mailimap_annotatemore_entry_match_list_free(
        mailimap_annotatemore_entry_match_list * en_list);

struct mailimap_annotatemore_attrib_match_list {
  clist * attrib_match_list; /* list of (char *) */
}
extern(C) mailimap_annotatemore_attrib_match_list *
mailimap_annotatemore_attrib_match_list_new(clist * at_list);
extern(C) void mailimap_annotatemore_attrib_match_list_free(
        mailimap_annotatemore_attrib_match_list * at_list);
extern(C) mailimap_annotatemore_entry_match_list *
mailimap_annotatemore_entry_match_list_new_empty();
extern(C) int mailimap_annotatemore_entry_match_list_add(
      mailimap_annotatemore_entry_match_list * en_list,
      char * entry);
extern(C) mailimap_annotatemore_attrib_match_list *
mailimap_annotatemore_attrib_match_list_new_empty();
extern(C) int mailimap_annotatemore_attrib_match_list_add(
      mailimap_annotatemore_attrib_match_list * at_list,
      char * attrib);

struct mailimap_annotatemore_entry_att_list {
  clist * entry_att_list; /* list of (mailimap_annotatemore_entry_att *) */
}
extern(C) mailimap_annotatemore_entry_att_list *
mailimap_annotatemore_entry_att_list_new(clist * en_list);
extern(C) void mailimap_annotatemore_entry_att_list_free(
      mailimap_annotatemore_entry_att_list * en_list);
extern(C) mailimap_annotatemore_entry_att_list *
mailimap_annotatemore_entry_att_list_new_empty();
extern(C) int mailimap_annotatemore_entry_att_list_add(
      mailimap_annotatemore_entry_att_list * en_list,
      mailimap_annotatemore_entry_att * en_att);

extern(C) void
mailimap_annotatemore_free(mailimap_extension_data * ext_data);

enum {
  MAIL_CHARCONV_NO_ERROR = 0,
  MAIL_CHARCONV_ERROR_UNKNOWN_CHARSET,
  MAIL_CHARCONV_ERROR_MEMORY,
  MAIL_CHARCONV_ERROR_CONV
}

/**
*	define your own conversion. 
*		- result is big enough to contain your converted string 
*		- result_len contain the maximum size available (out value must contain the final converted size)
*		- your conversion return an error code based on upper enum values
*/
extern(C) int function(const char * tocode, const char * fromcode, const char * str, size_t length,
    char * result, size_t* result_len) extended_charconv;
extern(C) int charconv(const char * tocode, const char * fromcode,
    const char * str, size_t length,
    char ** result);
extern(C) int charconv_buffer(const char * tocode, const char * fromcode,
		    const char * str, size_t length,
		    char ** result, size_t * result_len);
extern(C) void charconv_buffer_free(char * str);

struct chashdatum {
  void * data;
  uint len;
}

struct chash {
  uint size;
  uint count;
  int copyvalue;
  int copykey;
  chashcell ** cells; 
}

struct chashcell {
  uint func;
  chashdatum key;
  chashdatum value;
  chashcell * next;
}

alias chashcell chashiter;

immutable CHASH_COPYNONE   = 0;
immutable CHASH_COPYKEY    = 1;
immutable CHASH_COPYVALUE  = 2;
immutable CHASH_COPYALL    = (CHASH_COPYKEY | CHASH_COPYVALUE);

immutable CHASH_DEFAULTSIZE = 13;
  
/* Allocates a new (empty) hash using this initial size and the given flags,
   specifying which data should be copied in the hash.
    CHASH_COPYNONE  : Keys/Values are not copied.
    CHASH_COPYKEY   : Keys are dupped and freed as needed in the hash.
    CHASH_COPYVALUE : Values are dupped and freed as needed in the hash.
    CHASH_COPYALL   : Both keys and values are dupped in the hash.
 */
extern(C) chash * chash_new(uint size, int flags);

/* Frees a hash */
extern(C) void chash_free(chash * hash);

/* Removes all elements from a hash */
extern(C) void chash_clear(chash * hash);

/* Adds an entry in the hash table.
   Length can be 0 if key/value are strings.
   If an entry already exists for this key, it is replaced, and its value
   is returned. Otherwise, the data pointer will be NULL and the length
   field be set to TRUE or FALSe to indicate success or failure. */
extern(C) int chash_set(chash * hash,
	      chashdatum * key,
	      chashdatum * value,
	      chashdatum * oldvalue);

/* Retrieves the data associated to the key if it is found in the hash table.
   The data pointer and the length will be NULL if not found*/
extern(C) int chash_get(chash * hash,
	      chashdatum * key, chashdatum * result);

/* Removes the entry associated to this key if it is found in the hash table,
   and returns its contents if not dupped (otherwise, pointer will be NULL
   and len TRUE). If entry is not found both pointer and len will be NULL. */
extern(C) int chash_delete(chash * hash,
		 chashdatum * key,
		 chashdatum * oldvalue);

/* Resizes the hash table to the passed size. */
extern(C) int chash_resize(chash * hash, uint size);

/* Returns an iterator to the first non-empty entry of the hash table */
extern(C) chashiter * chash_begin(chash * hash);

/* Returns the next non-empty entry of the hash table */
extern(C) chashiter * chash_next(chash * hash, chashiter * iter);

/* Some of the following routines can be implemented as macros to
   be faster. If you don't want it, define NO_MACROS */
/* Returns the size of the hash table */
extern(C) uint          chash_size(chash * hash);

/* Returns the number of entries in the hash table */
extern(C) uint          chash_count(chash * hash);

/* Returns the key part of the entry pointed by the iterator */
extern(C) void chash_key(chashiter * iter, chashdatum * result);

/* Returns the value part of the entry pointed by the iterator */
extern(C) void chash_value(chashiter * iter, chashdatum * result);

uint chash_size(chash * hash)
{
  return hash.size;
}

uint chash_count(chash * hash)
{
  return hash.count;
}

void chash_key(chashiter * iter, chashdatum * result)
{
  * result = iter.key;
}

void chash_value(chashiter * iter, chashdatum * result)
{
  * result = iter.value;
}

extern(C) mailmessage * data_message_init(char * data, size_t len);
extern(C) void data_message_detach_mime(mailmessage * msg);

struct db_session_state_data {
  char db_filename[PATH_MAX];
  mail_flags_store * db_flags_store;
}

/* db storage */

/*
  db_mailstorage is the state data specific to the db storage.

  - pathname is the path of the db storage.
*/

struct db_mailstorage {
  char * db_pathname;
}

extern(C) int db_mailstorage_init(mailstorage * storage,
    char * db_pathname);

struct feed_session_state_data {
  time_t feed_last_update;
  newsfeed * feed_session;
  int feed_error;
}

struct feed_mailstorage {
  char * feed_url;

  int feed_cached;
  char * feed_cache_directory;
  char * feed_flags_directory;
}

extern(C) int feed_mailstorage_init(mailstorage * storage,
    const char * feed_url,
    int feed_cached, const char * feed_cache_directory,
    const char * feed_flags_directory);

struct mail_flags_store {
  carray * fls_tab;
  chash * fls_hash;
}

extern(C) int hotmail_mailstorage_init(mailstorage * storage,
    char * hotmail_login, char * hotmail_password,
    int hotmail_cached, char * hotmail_cache_directory,
    char * hotmail_flags_directory);


struct mailmessage_list {
  carray * msg_tab; /* elements are (mailmessage *) */
}
extern(C) mailmessage_list * mailmessage_list_new(carray * msg_tab);
extern(C) void mailmessage_list_free(mailmessage_list * env_list);

/*
  mail_list is a list of mailbox names

  - list is a list of mailbox names
*/

struct mail_list {
  clist * mb_list; /* elements are (char *) */
}
extern(C) mail_list * mail_list_new(clist * mb_list);
extern(C) void mail_list_free(mail_list * resp);

/*
  This is a flag value.
  Flags can be combined with OR operation
*/

enum {
  MAIL_FLAG_NEW       = 1 << 0,
  MAIL_FLAG_SEEN      = 1 << 1,
  MAIL_FLAG_FLAGGED   = 1 << 2,
  MAIL_FLAG_DELETED   = 1 << 3,
  MAIL_FLAG_ANSWERED  = 1 << 4,
  MAIL_FLAG_FORWARDED = 1 << 5,
  MAIL_FLAG_CANCELLED = 1 << 6
}

/*
  mail_flags is the value of a flag related to a message.
  
  - flags is the standard flags value

  - extension is a list of unknown flags for libEtPan!
*/

struct mail_flags {
  int fl_flags;
  clist * fl_extension; /* elements are (char *) */
}
extern(C) mail_flags * mail_flags_new(int fl_flags, clist * fl_ext);
extern(C) void mail_flags_free(mail_flags * flags);

/*
  This function creates a flag for a new message
*/
extern(C) mail_flags * mail_flags_new_empty();


/*
  mailimf_date_time_comp compares two dates
  
  
*/
extern(C) int mailimf_date_time_comp(mailimf_date_time * date1,
    mailimf_date_time * date2);

/*
  this is type type of the search criteria
*/

enum {
  MAIL_SEARCH_KEY_ALL,        /* all messages correspond */
  MAIL_SEARCH_KEY_ANSWERED,   /* messages with flag \Answered */
  MAIL_SEARCH_KEY_BCC,        /* messages which Bcc field contains
                                 a given string */
  MAIL_SEARCH_KEY_BEFORE,     /* messages which internal date is earlier
                                 than the specified date */
  MAIL_SEARCH_KEY_BODY,       /* message that contains the given string
                                 (in header and text parts) */
  MAIL_SEARCH_KEY_CC,         /* messages whose Cc field contains the
                                 given string */
  MAIL_SEARCH_KEY_DELETED,    /* messages with the flag \Deleted */
  MAIL_SEARCH_KEY_FLAGGED,    /* messages with the flag \Flagged */ 
  MAIL_SEARCH_KEY_FROM,       /* messages whose From field contains the
                                 given string */
  MAIL_SEARCH_KEY_NEW,        /* messages with the flag \Recent and not
                                 the \Seen flag */
  MAIL_SEARCH_KEY_OLD,        /* messages that do not have the
                                 \Recent flag set */
  MAIL_SEARCH_KEY_ON,         /* messages whose internal date is the
                                 specified date */
  MAIL_SEARCH_KEY_RECENT,     /* messages with the flag \Recent */
  MAIL_SEARCH_KEY_SEEN,       /* messages with the flag \Seen */
  MAIL_SEARCH_KEY_SINCE,      /* messages whose internal date is later
                                 than specified date */
  MAIL_SEARCH_KEY_SUBJECT,    /* messages whose Subject field contains the
                                 given string */
  MAIL_SEARCH_KEY_TEXT,       /* messages whose text part contains the
                                 given string */
  MAIL_SEARCH_KEY_TO,         /* messages whose To field contains the
                                 given string */
  MAIL_SEARCH_KEY_UNANSWERED, /* messages with no flag \Answered */
  MAIL_SEARCH_KEY_UNDELETED,  /* messages with no flag \Deleted */
  MAIL_SEARCH_KEY_UNFLAGGED,  /* messages with no flag \Flagged */
  MAIL_SEARCH_KEY_UNSEEN,     /* messages with no flag \Seen */
  MAIL_SEARCH_KEY_HEADER,     /* messages whose given field 
                                 contains the given string */
  MAIL_SEARCH_KEY_LARGER,     /* messages whose size is larger then
                                 the given size */
  MAIL_SEARCH_KEY_NOT,        /* not operation of the condition */
  MAIL_SEARCH_KEY_OR,         /* or operation between two conditions */
  MAIL_SEARCH_KEY_SMALLER,    /* messages whose size is smaller than
                                 the given size */
  MAIL_SEARCH_KEY_MULTIPLE    /* the boolean operator between the
                                 conditions is AND */
}

/*
  mail_search_key is the condition on the messages to return
  
  - type is the type of the condition

  - bcc is the text to search in the Bcc field when type is
    MAIL_SEARCH_KEY_BCC, should be allocated with malloc()

  - before is a date when type is MAIL_SEARCH_KEY_BEFORE

  - body is the text to search in the message when type is
    MAIL_SEARCH_KEY_BODY, should be allocated with malloc()

  - cc is the text to search in the Cc field when type is
    MAIL_SEARCH_KEY_CC, should be allocated with malloc()
  
  - from is the text to search in the From field when type is
    MAIL_SEARCH_KEY_FROM, should be allocated with malloc()

  - on is a date when type is MAIL_SEARCH_KEY_ON

  - since is a date when type is MAIL_SEARCH_KEY_SINCE
  
  - subject is the text to search in the Subject field when type is
    MAILIMAP_SEARCH_KEY_SUBJECT, should be allocated with malloc()

  - text is the text to search in the text part of the message when
    type is MAILIMAP_SEARCH_KEY_TEXT, should be allocated with malloc()

  - to is the text to search in the To field when type is
    MAILIMAP_SEARCH_KEY_TO, should be allocated with malloc()

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

  - multiple is a set of message when type is MAILIMAP_SEARCH_KEY_MULTIPLE
*/

/+#if 0
struct mail_search_key {
  int sk_type;
  union {
    char * sk_bcc;
    struct mailimf_date_time * sk_before;
    char * sk_body;
    char * sk_cc;
    char * sk_from;
    struct mailimf_date_time * sk_on;
    struct mailimf_date_time * sk_since;
    char * sk_subject;
    char * sk_text;
    char * sk_to;
    char * sk_header_name;
    char * sk_header_value;
    size_t sk_larger;
    struct mail_search_key * sk_not;
    struct mail_search_key * sk_or1;
    struct mail_search_key * sk_or2;
    size_t sk_smaller;
    clist * sk_multiple; /* list of (struct mailimap_search_key *) */
  } sk_data;
};


extern(C) struct mail_search_key *
mail_search_key_new(int sk_type,
    char * sk_bcc, mailimf_date_time * sk_before,
    char * sk_body, char * sk_cc, char * sk_from,
    mailimf_date_time * sk_on, mailimf_date_time * sk_since,
    char * sk_subject, char * sk_text, char * sk_to,
    char * sk_header_name, char * sk_header_value, size_t sk_larger,
    mail_search_key * sk_not, mail_search_key * sk_or1,
    mail_search_key * sk_or2, size_t sk_smaller,
    clist * sk_multiple);

extern(C) void mail_search_key_free(mail_search_key * key);
+/

/*
  mail_search_result is a list of message numbers that is returned
  by the mailsession_search_messages function()
*/

/+
struct mail_search_result {
  clist * sr_list; /* list of (int *) */
}

extern(C) mail_search_result * mail_search_result_new(clist * sr_list);

extern(C) void mail_search_result_free(mail_search_result * search_result);
+/


/*
  There is three kinds of identities :
  - storage
  - folders
  - session

  A storage (struct mailstorage) represents whether a server or
  a main path,

  A storage can be an IMAP server, the root path of a MH or a mbox file.

  Folders (struct mailfolder) are the mailboxes we can
  choose in the server or as sub-folder of the main path.

  Folders for IMAP are the IMAP mailboxes, for MH this is one of the
  folder of the MH storage, for mbox, there is only one folder, the
  mbox file content;

  A mail session (struct mailsession) is whether a connection to a server
  or a path that is open. It is the abstraction lower folders and storage.
  It allow us to send commands.

  We have a session driver for mail session for each kind of storage.

  From a session, we can get a message (struct mailmessage) to read.
  We have a message driver for each kind of storage.
*/

/*
  maildriver is the driver structure for mail sessions

  - name is the name of the driver
  
  - initialize() is the function that will initializes a data structure
      specific to the driver, it returns a value that will be stored
      in the field data of the session.
      The field data of the session is the state of the session,
      the internal data structure used by the driver.
      It is called when creating the mailsession structure with
      mailsession_new().
  
  - uninitialize() frees the structure created with initialize()

  - parameters() implements functions specific to the given mail access
  
  - connect_stream() connects a stream to the session

  - connect_path() notify a main path to the session

  - starttls() changes the current stream to a TLS stream
  
  - login() notifies the user and the password to authenticate to the
      session

  - logout() exits the session and closes the stream

  - noop() does no operation on the session, but it can be
      used to poll for the status of the connection.

  - build_folder_name() will return an allocated string with
      that contains the complete path of the folder to create

  - create_folder() creates the folder that corresponds to the
      given name

  - delete_folder() deletes the folder that corresponds to the
      given name

  - rename_folder() change the name of the folder

  - check_folder() makes a checkpoint of the session

  - examine_folder() selects a mailbox as readonly

  - select_folder() selects a mailbox

  - expunge_folder() deletes all messages marked \Deleted

  - status_folder() queries the status of the folder
      (number of messages, number of recent messages, number of
      unseen messages)

  - messages_number() queries the number of messages in the folder

  - recent_number() queries the number of recent messages in the folder

  - unseen_number() queries the number of unseen messages in the folder

  - list_folders() returns the list of all sub-mailboxes
      of the given mailbox

  - lsub_folders() returns the list of subscribed
      sub-mailboxes of the given mailbox

  - subscribe_folder() subscribes to the given mailbox

  - unsubscribe_folder() unsubscribes to the given mailbox

  - append_message() adds a RFC 2822 message to the current
      given mailbox

  - copy_message() copies a message whose number is given to
       a given mailbox. The mailbox must be accessible from
       the same session.

  - move_message() copies a message whose number is given to
       a given mailbox. The mailbox must be accessible from the
       same session.

  - get_messages_list() returns the list of message numbers
      of the current mailbox.

  - get_envelopes_list() fills the parsed fields in the
      mailmessage structures of the mailmessage_list.

  - remove_message() removes the given message from the mailbox.
      The message is permanently deleted.

  - search_message() returns a list of message numbers that
      corresponds to the given criteria.

  - get_message returns a mailmessage structure that corresponds
      to the given message number.

  - get_message_by_uid returns a mailmessage structure that corresponds
      to the given message unique identifier.

  * mandatory functions are the following :

  - connect_stream() of connect_path()
  - logout()
  - get_messages_list()
  - get_envelopes_list()

  * we advise you to implement these functions :

  - select_folder() (in case a session can access several folders)
  - noop() (to check if the server is responding)
  - check_folder() (to make a checkpoint of the session)
  - status_folder(), messages_number(), recent_number(), unseen_number()
      (to get stat of the folder)
  - append_message() (but can't be done in the case of POP3 at least)
  - login() in a case of an authenticated driver.
  - starttls() in a case of a stream driver, if the procotol supports
      STARTTLS.
  - get_message_by_uid() so that the application can remember the message
      by UID and build its own list of messages.
  - login_sasl() notifies the SASL information to authenticate to the
      session.

  * drivers' specific :

  Everything that is specific to the driver will be implemented in this
  function :

  - parameters()
*/

struct mailsession_driver {
  char * sess_name;

  int function(mailsession * session) sess_initialize;
  void function(mailsession * session) sess_uninitialize;

  int function(mailsession * session,
      int id, void * value) sess_parameters;

  int function(mailsession * session, mailstream * s) sess_connect_stream;
  int function(mailsession * session, const char * path) sess_connect_path;

  int function(mailsession * session) sess_starttls;

  int function(mailsession * session, const char * userid, const char * password) sess_login;
  int function(mailsession * session) sess_logout;
  int function(mailsession * session) sess_noop;

  /* folders operations */

  int function(mailsession * session, const char * mb, const char * name, char ** result) sess_build_folder_name;

  int function(mailsession * session, const char * mb) sess_create_folder;
  int function(mailsession * session, const char * mb) sess_delete_folder;
  int function(mailsession * session, const char * mb, const char * new_name) sess_rename_folder;
  int function(mailsession * session) sess_check_folder;
  int function(mailsession * session, const char * mb) sess_examine_folder;
  int function(mailsession * session, const char * mb) sess_select_folder;
  int function(mailsession * session) sess_expunge_folder;
  int function(mailsession * session, const char * mb, int * result_num,
		  int * result_recent, int * result_unseen)
	  sess_status_folder;
  int function(mailsession * session, const char * mb, int * result) sess_messages_number;
  int function(mailsession * session, const char * mb, int * result) sess_recent_number;
  int function(mailsession * session, const char * mb, int * result) sess_unseen_number;

  int function(mailsession * session, const char * mb, mail_list ** result) sess_list_folders;
  int function(mailsession * session, const char * mb, mail_list ** result) sess_lsub_folders;

  int function(mailsession * session, const char * mb) sess_subscribe_folder;
  int function(mailsession * session, const char * mb) sess_unsubscribe_folder;

  /* messages operations */

  int function(mailsession * session, const char * message, size_t size) sess_append_message;
  int function(mailsession * session, const char * message, size_t size, mail_flags * flags) 
	  sess_append_message_flags;
  int function(mailsession * session, int num, const char * mb) sess_copy_message;
  int function(mailsession * session, int num, const char * mb) sess_move_message;

  int function(mailsession * session, int num, mailmessage ** result) sess_get_message;

  int function(mailsession * session, const char * uid, mailmessage ** result) sess_get_message_by_uid;
  
  int function(mailsession * session, mailmessage_list ** result) sess_get_messages_list;
  int function(mailsession * session, mailmessage_list * env_list) sess_get_envelopes_list;
  int function(mailsession * session, int num) sess_remove_message;
  
  int function(mailsession * session, const char * auth_type, const char * server_fqdn, 
		 const char * local_ip_port, const char * remote_ip_port, const char * login, 
		 const char * auth_name, const char * password, const char * realm) sess_login_sasl;
}

/*
  session is the data structure for a mail session.

  - data is the internal data structure used by the driver
    It is called when initializing the mailsession structure.

  - driver is the driver used for the session
*/

struct mailsession {
  void * sess_data;
  mailsession_driver * sess_driver;
}

/*
  mailmessage_driver is the driver structure to get information from messages.
  
  - name is the name of the driver

  - initialize() is the function that will initializes a data structure
      specific to the driver, it returns a value that will be stored
      in the field data of the mailsession.
      The field data of the session is the state of the session,
      the internal data structure used by the driver.
      It is called when initializing the mailmessage structure with
      mailmessage_init().
  
  - uninitialize() frees the structure created with initialize().
      It will be called by mailmessage_free().

  - flush() will free from memory all temporary structures of the message
      (for example, the MIME structure of the message).

  - fetch_result_free() will free all strings resulted by fetch() or
      any fetch_xxx() functions that returns a string.

  - fetch() returns the content of the message (headers and text).

  - fetch_header() returns the content of the headers.

  - fetch_body() returns the message text (message content without headers)

  - fetch_size() returns the size of the message content.

  - get_bodystructure() returns the MIME structure of the message.

  - fetch_section() returns the content of a given MIME part

  - fetch_section_header() returns the header of the message
      contained by the given MIME part.

  - fetch_section_mime() returns the MIME headers of the
      given MIME part.

  - fetch_section_body() returns the text (if this is a message, this is the
      message content without headers) of the given MIME part.

  - fetch_envelope() returns a mailimf_fields structure, with a list of
      fields chosen by the driver.

  - get_flags() returns a the flags related to the message.
      When you want to get flags of a message, you have to make sure to
      call get_flags() at least once before using directly message.flags.
*/

struct mailmessage_driver {
  char * msg_name;

  int function(mailmessage * msg_info) msg_initialize; 
  void function(mailmessage * msg_info) msg_uninitialize;
  
  void function(mailmessage * msg_info) msg_flush;

  void function(mailmessage * msg_info) msg_check;

  void function(mailmessage * msg_info, char * msg) msg_fetch_result_free;

  int function(mailmessage * msg_info, char ** result, size_t * result_len) msg_fetch;
       
  int function(mailmessage * msg_info, char ** result, size_t * result_len) msg_fetch_header;
  
  int function(mailmessage * msg_info, char ** result, size_t * result_len) msg_fetch_body;

  int function(mailmessage * msg_info, size_t * result) msg_fetch_size;
  
  int function(mailmessage * msg_info, mailmime ** result) msg_get_bodystructure;
 
  int function(mailmessage * msg_info, mailmime * mime, char ** result, size_t * result_len) msg_fetch_section;
  
  int function(mailmessage * msg_info, mailmime * mime, char ** result, size_t * result_len) msg_fetch_section_header;
  
  int function(mailmessage * msg_info, mailmime * mime, char ** result, size_t * result_len) msg_fetch_section_mime;
  
  int function(mailmessage * msg_info, mailmime * mime, char ** result, size_t * result_len) msg_fetch_section_body;

  int function(mailmessage * msg_info, mailimf_fields ** result) msg_fetch_envelope;

  int function(mailmessage * msg_info, mail_flags ** result) msg_get_flags;
}


/*
  mailmessage is a data structure to get information from messages

  - session is the session linked to the given message, it can be NULL

  - driver is the message driver
  
  - index is the message number

  - uid, when it is not NULL, it means that the folder 
      the folder has persistant message numbers, the string is
      the unique message number in the folder.
      uid should be implemented if possible.
      for drivers where we cannot generate real uid,
      a suggestion is "AAAA-IIII" where AAAA is some
      random session number and IIII the content of index field.

  - size, when it is not 0, is the size of the message content.
  
  - fields, when it is not NULL, are the header fields of the message.

  - flags, when it is not NULL, are the flags related to the message.

  - single_fields, when resolved != 0, is filled with the data of fields.

  - mime, when it is not NULL

  - cached is != 0 when the header fields were read from the cache.
  
  - data is data specific to the driver, this is internal data structure,
      some state of the message.
*/

struct mailmessage {
  mailsession * msg_session;
  mailmessage_driver * msg_driver;
  int msg_index;
  char * msg_uid;

  size_t msg_size;
  mailimf_fields * msg_fields;
  mail_flags * msg_flags;

  int msg_resolved;
  mailimf_single_fields msg_single_fields;
  mailmime * msg_mime;

  /* internal data */
  int msg_cached;
  void * msg_data;
  
 /*
   msg_folder field :
   used to reference the mailfolder, this is a workaround due
   to the problem with initial conception, where folder notion
   did not exist.
 */
  void * msg_folder;
  /* user data */
  void * msg_user_data;
}


/*
  mailmessage_tree is a node in the messages tree (thread)
  
  - node_parent is the parent of the message, it is NULL if the message
      is the root of the message tree.

  - node_msgid is the message ID of this node.

  - node_date is the date of the message in number of second elapsed
      since 00:00:00 on January 1, 1970, Coordinated Universal Time (UTC).

  - node_msg is the message structure that is stored referenced by the node.
      is msg is NULL, this is a dummy node.

  - node_children is an array that contains all the children of the node.
      children are mailmessage_tree structures.

  - node_is_reply is != 0 when the message is a reply or a forward

  - node_base_subject is the extracted subject of the message.
*/

struct mailmessage_tree {
  mailmessage_tree * node_parent;
  char * node_msgid;
  time_t node_date;
  mailmessage * node_msg;
  carray * node_children; /* array of (struct mailmessage_tree *) */

  /* private, used for threading */
  int node_is_reply;
  char * node_base_subject;
}
extern(C) mailmessage_tree *
mailmessage_tree_new(char * node_msgid, time_t node_date,
    mailmessage * node_msg);
extern(C) void mailmessage_tree_free(mailmessage_tree * tree);

/*
  mailmessage_tree_free_recursive

  if you want to release memory of the given tree and all the sub-trees,
  you can use this function.
*/
extern(C) void mailmessage_tree_free_recursive(mailmessage_tree * tree);


struct generic_message_t {
  int function(mailmessage * msg_info) msg_prefetch;
  void function(generic_message_t * msg) msg_prefetch_free;
  int msg_fetched;
  char * msg_message;
  size_t msg_length;
  void * msg_data;
}

extern(C) const(char)* maildriver_strerror(int err);

/* basic malloc / free functions to be compliant with the library allocations */
extern(C) void *libetpan_malloc(size_t length);
extern(C) void libetpan_free(void* data);

extern(C) int mailimap_idle(mailimap * session);
extern(C) int mailimap_idle_done(mailimap * session);
extern(C) int mailimap_idle_get_fd(mailimap * session);

extern(C) void mailimap_idle_set_delay(mailimap * session, long delay);
extern(C) long mailimap_idle_get_done_delay(mailimap * session);
extern(C) int mailimap_has_idle(mailimap * session);

extern(C) int
imap_section_to_imap_section(mailmime_section * section, int type,
    mailimap_section ** result);
extern(C) int imap_get_msg_att_info(mailimap_msg_att * msg_att,
    int * puid,
    mailimap_envelope ** pimap_envelope,
    char ** preferences,
    size_t * pref_size,
    mailimap_msg_att_dynamic ** patt_dyn,
    mailimap_body ** pimap_body);
extern(C) int imap_add_envelope_fetch_att(mailimap_fetch_type * fetch_type);
extern(C) int imap_env_to_fields(mailimap_envelope * env,
    char * ref_str, size_t ref_size,
    mailimf_fields ** result);
extern(C) int
imap_fetch_result_to_envelop_list(clist * fetch_result,
    mailmessage_list * env_list);
extern(C) int imap_body_to_body(mailimap_body * imap_body,
    mailmime ** result);
extern(C) int imap_msg_list_to_imap_set(clist * msg_list,
    mailimap_set ** result);
extern(C) int imap_flags_to_imap_flags(mail_flags * flags,
    mailimap_flag_list ** result);
extern(C) int imap_flags_to_flags(mailimap_msg_att_dynamic * att_dyn,
    mail_flags ** result);

extern(C) int
imapdriver_get_cached_envelope(mail_cache_db * cache_db,
    MMAPString * mmapstr,
    mailsession * session, mailmessage * msg,
    mailimf_fields ** result);

extern(C) int imapdriver_write_cached_envelope(mail_cache_db * cache_db,
    MMAPString * mmapstr,
    mailsession * session, mailmessage * msg,
    mailimf_fields * fields);
extern(C) int imap_error_to_mail_error(int error);
extern(C) int imap_store_flags(mailimap * imap, int first, int last,
    mail_flags * flags);
extern(C) int imap_fetch_flags(mailimap * imap,
    int indx, mail_flags ** result);
extern(C) int imap_get_messages_list(mailimap * imap,
    mailsession * session, mailmessage_driver * driver,
    int first_index, mailmessage_list ** result);

struct imap_session_state_data {
  mailimap * imap_session;
  char * imap_mailbox;
  mail_flags_store * imap_flags_store;
  void function(mailstream_ssl_context * ssl_context, void * data) imap_ssl_callback;
  void * imap_ssl_cb_data;
}

enum {
  IMAP_SECTION_MESSAGE,
  IMAP_SECTION_HEADER,
  IMAP_SECTION_MIME,
  IMAP_SECTION_BODY
}

/* cached IMAP driver for session */

enum {
  IMAPDRIVER_CACHED_SET_SSL_CALLBACK = 1,
  IMAPDRIVER_CACHED_SET_SSL_CALLBACK_DATA = 2,
  /* cache */
  IMAPDRIVER_CACHED_SET_CACHE_DIRECTORY = 1001
}

struct imap_cached_session_state_data {
  mailsession * imap_ancestor;
  char * imap_quoted_mb;
  char imap_cache_directory[PATH_MAX];
  carray * imap_uid_list;
  int imap_uidvalidity;
}


/* IMAP storage */

/*
  imap_mailstorage is the state data specific to the IMAP4rev1 storage.

  - servername  this is the name of the IMAP4rev1 server
  
  - port is the port to connect to, on the server.
    you give 0 to use the default port.

  - command, if non-NULL the command used to connect to the
    server instead of allowing normal TCP connections to be used.
    
  - connection_type is the type of socket layer to use.
    The value can be CONNECTION_TYPE_PLAIN, CONNECTION_TYPE_STARTTLS,
    CONNECTION_TYPE_TRY_STARTTLS, CONNECTION_TYPE_TLS or
    CONNECTION_TYPE_COMMAND.

  - auth_type is the authenticate mechanism to use.
    The value can be IMAP_AUTH_TYPE_PLAIN.
    Other values are not yet implemented.

  - login is the login of the IMAP4rev1 account.

  - password is the password of the IMAP4rev1 account.

  - cached if this value is != 0, a persistant cache will be
    stored on local system.

  - cache_directory is the location of the cache
*/

struct imap_mailstorage {
  char * imap_servername;
  short imap_port;
  char * imap_command;
  int imap_connection_type;
  
  int imap_auth_type;
  char * imap_login; /* deprecated */
  char * imap_password; /* deprecated */
  
  int imap_cached;
  char * imap_cache_directory;
  
  struct imap_sasl_t{
    int sasl_enabled;
    char * sasl_auth_type;
    char * sasl_server_fqdn;
    char * sasl_local_ip_port;
    char * sasl_remote_ip_port;
    char * sasl_login;
    char * sasl_auth_name;
    char * sasl_password;
    char * sasl_realm;
  } 
  
  imap_sasl_t imap_sasl;
  
  char * imap_local_address;
  short imap_local_port;
}

/* this is the type of IMAP4rev1 authentication */

enum {
  IMAP_AUTH_TYPE_PLAIN,            /* plain text authentication */
  IMAP_AUTH_TYPE_SASL_ANONYMOUS,   /* SASL anonymous */
  IMAP_AUTH_TYPE_SASL_CRAM_MD5,    /* SASL CRAM MD5 */
  IMAP_AUTH_TYPE_SASL_KERBEROS_V4, /* SASL KERBEROS V4 */
  IMAP_AUTH_TYPE_SASL_PLAIN,       /* SASL plain */
  IMAP_AUTH_TYPE_SASL_SCRAM_MD5,   /* SASL SCRAM MD5 */
  IMAP_AUTH_TYPE_SASL_GSSAPI,      /* SASL GSSAPI */
  IMAP_AUTH_TYPE_SASL_DIGEST_MD5   /* SASL digest MD5 */
}

/*
  imap_mailstorage_init is the constructor for a IMAP4rev1 storage

  @param storage this is the storage to initialize.

  @param servername  this is the name of the IMAP4rev1 server
  
  @param port is the port to connect to, on the server.
    you give 0 to use the default port.

  @param command the command used to connect to the server instead of
    allowing normal TCP connections to be used.

  @param connection_type is the type of socket layer to use.
    The value can be CONNECTION_TYPE_PLAIN, CONNECTION_TYPE_STARTTLS,
    CONNECTION_TYPE_TRY_STARTTLS, CONNECTION_TYPE_TLS,
    CONNECTION_TYPE_COMMAND, CONNECTION_TYPE_COMMAND_STARTTLS,
    CONNECTION_TYPE_COMMAND_TRY_STARTTLS, CONNECTION_TYPE_COMMAND_TLS,.
    
  @param auth_type is the authenticate mechanism to use.
    The value can be IMAP_AUTH_TYPE_PLAIN.
    Other values are not yet implemented.

  @param login is the login of the IMAP4rev1 account.

  @param password is the password of the IMAP4rev1 account.

  @param cached if this value is != 0, a persistant cache will be
    stored on local system.

  @param cache_directory is the location of the cache
*/
extern(C) int imap_mailstorage_init(mailstorage * storage,
    const char * imap_servername, uint16_t imap_port,
    const char * imap_command,
    int imap_connection_type, int imap_auth_type,
    const char * imap_login, const char * imap_password,
    int imap_cached, const char * imap_cache_directory);

extern(C) int imap_mailstorage_init_sasl(mailstorage * storage,
    const char * imap_servername, uint16_t imap_port,
    const char * imap_command,
    int imap_connection_type,
    const char * auth_type,
    const char * server_fqdn,
    const char * local_ip_port,
    const char * remote_ip_port,
    const char * login, const char * auth_name,
    const char * password, const char * realm,
    int imap_cached, const char * imap_cache_directory);
extern(C) int imap_mailstorage_init_sasl_with_local_address(mailstorage * storage,
    const char * imap_servername, uint16_t imap_port,
    const char * imap_local_address, uint16_t imap_local_port,
    const char * imap_command,
    int imap_connection_type,
    const char * auth_type,
    const char * server_fqdn,
    const char * local_ip_port,
    const char * remote_ip_port,
    const char * login, const char * auth_name,
    const char * password, const char * realm,
    int imap_cached, const char * imap_cache_directory);

struct maildir_session_state_data {
  maildir * md_session;
  mail_flags_store * md_flags_store;
}

enum {
  MAILDIRDRIVER_CACHED_SET_CACHE_DIRECTORY = 1,
  MAILDIRDRIVER_CACHED_SET_FLAGS_DIRECTORY
}

struct maildir_cached_session_state_data {
  mailsession * md_ancestor;
  char * md_quoted_mb;
  mail_flags_store * md_flags_store;
  char md_cache_directory[PATH_MAX];
  char md_flags_directory[PATH_MAX];
}

/* maildir storage */

/*
  maildir_mailstorage is the state data specific to the maildir storage.

  - pathname is the path of the maildir storage.
  
  - cached if this value is != 0, a persistant cache will be
      stored on local system.
  
  - cache_directory is the location of the cache.

  - flags_directory is the location of the flags.
*/

struct maildir_mailstorage {
  char * md_pathname;
  
  int md_cached;
  char * md_cache_directory;
  char * md_flags_directory;
}
extern(C) maildir * maildir_new(const char * path);

extern(C) 
int maildir_update(maildir * md);
extern(C) int maildir_message_add_uid(maildir * md,
    const char * message, size_t size,
    char * uid, size_t max_uid_len);
extern(C) int maildir_message_add(maildir * md,
    const char * message, size_t size);
extern(C) int maildir_message_add_file_uid(maildir * md, int fd,
    char * uid, size_t max_uid_len);
extern(C) int maildir_message_add_file(maildir * md, int fd);
extern(C) char * maildir_message_get(maildir * md, const char * uid);
extern(C) int maildir_message_remove(maildir * md, const char * uid);
extern(C) int maildir_message_change_flags(maildir * md,
    const char * uid, int new_flags);


extern(C) int maildir_mailstorage_init(mailstorage * storage,
    const char * md_pathname, int md_cached,
    const char * md_cache_directory, const char * md_flags_directory);

enum {
  MAILDIR_NO_ERROR = 0,
  MAILDIR_ERROR_CREATE,
  MAILDIR_ERROR_DIRECTORY,
  MAILDIR_ERROR_MEMORY,
  MAILDIR_ERROR_FILE,
  MAILDIR_ERROR_NOT_FOUND,
  MAILDIR_ERROR_FOLDER
}

immutable MAILDIR_FLAG_NEW      = (1 << 0);
immutable MAILDIR_FLAG_SEEN     = (1 << 1);
immutable MAILDIR_FLAG_REPLIED  = (1 << 2);
immutable MAILDIR_FLAG_FLAGGED  = (1 << 3);
immutable MAILDIR_FLAG_TRASHED  = (1 << 4);

struct maildir_msg {
  char * msg_uid;
  char * msg_filename;
  int msg_flags;
}

/*
  work around for missing #define HOST_NAME_MAX in Linux
*/

immutable HOST_NAME_MAX = 255;

struct maildir {
  pid_t mdir_pid;
  char mdir_hostname[HOST_NAME_MAX];
  char mdir_path[PATH_MAX];
  uint mdir_counter;
  time_t mdir_mtime_new;
  time_t mdir_mtime_cur;
  carray * mdir_msg_list;
  chash * mdir_msg_hash;
}

































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
