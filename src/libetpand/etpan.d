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
}

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
}

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
}

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
}

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
}

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
}


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

/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: maildriver_types_helper.h,v 1.6 2004/11/21 21:53:35 hoa Exp $
 */
/*
  mail_flags_add_extension adds the given flag if it does not exists in
  the flags.

  @param flags this is the flag to change

  @param ext_flag this is the name of an extension flag
    the given flag name is duplicated and is no more needed after
    the function call.

  @return MAIL_NO_ERROR is returned on success, MAIL_ERROR_XXX is returned
    on error
*/
extern(C) 
int mail_flags_add_extension(mail_flags * flags,
			     char * ext_flag);

/*
  mail_flags_remove_extension removes the given flag if it does not exists in
  the flags.

  @param flags this is the flag to change

  @param ext_flag this is the name of an extension flag
    the given flag name is no more needed after the function call.

  @return MAIL_NO_ERROR is returned on success, MAIL_ERROR_XXX is returned
    on error
*/
extern(C) 
int mail_flags_remove_extension(mail_flags * flags,
				char * ext_flag);

/*
  mail_flags_has_extension returns 1 if the flags is in the given flags,
    0 is returned otherwise.

  @param flags this is the flag to change

  @param ext_flag this is the name of an extension flag
    the given flag name is no more needed after the function call.

  @return MAIL_NO_ERROR is returned on success, MAIL_ERROR_XXX is returned
    on error
*/
extern(C) 
int mail_flags_has_extension(mail_flags * flags,
			     char * ext_flag);

/*
 * libEtPan! -- a mail library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mailengine.h,v 1.3 2004/11/21 21:53:35 hoa Exp $
 */
/*
  to run things in thread, you must protect the storage again concurrency.
*/


/*
  storage data
*/
extern(C) 
mailengine *
libetpan_engine_new(mailprivacy * privacy);
extern(C) 
void libetpan_engine_free(mailengine * engine);

extern(C) mailprivacy *
libetpan_engine_get_privacy(mailengine * engine);


/*
  message ref and unref
*/

/*
  these function can only take messages returned by get_msg_list()
  as arguments.
  
  these functions cannot fail.
*/
extern(C) 
int libetpan_message_ref(mailengine * engine,
    mailmessage * msg);
extern(C) 
int libetpan_message_unref(mailengine * engine,
    mailmessage * msg);

/*
  when you want to access the MIME structure of the message
  with msg->mime, you have to call libetpan_message_mime_ref()
  and libetpan_message_mime_unref() when you have finished.
  
  if libetpan_mime_ref() returns a value <= 0, it means this failed.
  the value is -MAIL_ERROR_XXX
*/
extern(C) 
int libetpan_message_mime_ref(mailengine * engine,
    mailmessage * msg);
extern(C) 
int libetpan_message_mime_unref(mailengine * engine,
    mailmessage * msg);

/*
  message list
*/

/*
  libetpan_folder_get_msg_list()
  
  This function returns two list.
  - List of lost message (the messages that were previously returned
    but that does no more exist) (p_lost_msg_list)
  - List of valid messages (p_new_msg_list).

  These two list can only be freed by libetpan_folder_free_msg_list()
*/
extern(C) 
int libetpan_folder_get_msg_list(mailengine * engine,
    mailfolder * folder,
    mailmessage_list ** p_new_msg_list,
    mailmessage_list ** p_lost_msg_list);
extern(C) 
int libetpan_folder_fetch_env_list(mailengine * engine,
    mailfolder * folder,
    mailmessage_list * msg_list);
extern(C) 
void libetpan_folder_free_msg_list(mailengine * engine,
    mailfolder * folder,
    mailmessage_list * env_list);


/*
  connect and disconnect storage
*/
extern(C) 
int libetpan_storage_add(mailengine * engine,
    mailstorage * storage);
extern(C) 
void libetpan_storage_remove(mailengine * engine,
    mailstorage * storage);
extern(C) 
int libetpan_storage_connect(mailengine * engine,
    mailstorage * storage);
extern(C) 
void libetpan_storage_disconnect(mailengine * engine,
    mailstorage * storage);
extern(C) 
int libetpan_storage_used(mailengine * engine,
    mailstorage * storage);


/*
  libetpan_folder_connect()
  libetpan_folder_disconnect()
  
  You can disconnect the folder only when you have freed all the message
  you were given.
*/
extern(C) 
int libetpan_folder_connect(mailengine * engine,
    mailfolder * folder);
extern(C) 
void libetpan_folder_disconnect(mailengine * engine,
    mailfolder * folder);

extern(C) mailfolder *
libetpan_message_get_folder(mailengine * engine,
    mailmessage * msg);
extern(C) 
mailstorage *
libetpan_message_get_storage(mailengine * engine,
    mailmessage * msg);

/*
  register a message
*/
extern(C) 
int libetpan_message_register(mailengine * engine,
    mailfolder * folder,
    mailmessage * msg);

extern(C) 
void libetpan_engine_debug(mailengine * engine, FILE * f);

/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mailfolder.h,v 1.4 2006/04/06 22:54:56 hoa Exp $
 */
extern(C) 
int mailfolder_noop(mailfolder * folder);
extern(C) 
int mailfolder_check(mailfolder * folder);
extern(C) int mailfolder_expunge(mailfolder * folder);
extern(C) int mailfolder_status(mailfolder * folder,
    uint * result_messages, uint * result_recent,
    uint * result_unseen);
extern(C) int mailfolder_append_message(mailfolder * folder,
    char * message, size_t size);
extern(C) int mailfolder_append_message_flags(mailfolder * folder,
    char * message, size_t size, mail_flags * flags);
extern(C) int mailfolder_get_messages_list(mailfolder * folder,
    mailmessage_list ** result);
extern(C) int mailfolder_get_envelopes_list(mailfolder * folder,
    mailmessage_list * result);
extern(C) int mailfolder_get_message(mailfolder * folder,
    uint num, mailmessage ** result);
extern(C) int mailfolder_get_message_by_uid(mailfolder * folder,
    const char * uid, mailmessage ** result);
/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mail.h,v 1.8 2004/11/21 21:53:31 hoa Exp $
 */
/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
/*
  you add a (static) mailimap_extension_api to the list of extensions
  by calling register. making the list of
  extensions contain all extensions statically may prove detrimental
  to speed if you have many extensions and don't need any of them.
  as unregistering single extensions does not really make any sense,
  it's not provided - just an unregister_all which is primarily used
  to free the clist on exit.
*/

extern(C) int mailimap_extension_register(mailimap_extension_api * extension);
extern(C) void mailimap_extension_unregister_all();

/*
  this is called as the main parser wrapper for all extensions.
  it gos through the list of registered extensions and calls
  all of the extensions' parsers looking for one that doesn't
  return MAILIMAP_ERROR_PARSE.
*/
extern(C) int mailimap_extension_data_parse(int calling_parser,
        mailstream * fd, MMAPString * buffer,
        size_t * indx, mailimap_extension_data ** result,
        size_t progr_rate,
        progress_function * progr_fun);
extern(C) mailimap_extension_data *
mailimap_extension_data_new(mailimap_extension_api * extension,
        int type, void * data);

/*
  wrapper for the extensions' free. calls the correct extension's free
  based on data->extension.
*/
extern(C) void mailimap_extension_data_free(
        mailimap_extension_data * data);

/*
  stores the ext_data in the session (only needed for extensions
  that embed directly into response-data).
*/
extern(C) void mailimap_extension_data_store(mailimap * session,
    mailimap_extension_data ** ext_data);

/*
  return 1 if the extension of the given name is supported.
  the name is searched in the capabilities.
*/
extern(C) int mailimap_has_extension(mailimap * session, char * extension_name);


/*
  this is the list of known extensions with the purpose to
  get integer identifers for the extensions.
*/

/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mailimap.h,v 1.23 2011/03/29 23:59:05 hoa Exp $
 */

/*
  mailimap_connect()

  This function will connect the IMAP session with the given stream.

  @param session  the IMAP session
  @param s        stream to use

  @return the return code is one of MAILIMAP_ERROR_XXX or
    MAILIMAP_NO_ERROR codes
  
  note that on success, MAILIMAP_NO_ERROR_AUTHENTICATED or
    MAILIMAP_NO_ERROR_NON_AUTHENTICATED is returned

  MAILIMAP_NO_ERROR_NON_AUTHENTICATED is returned when you need to
  use mailimap_login() to authenticate, else
  MAILIMAP_NO_ERROR_AUTHENTICATED is returned.
*/

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
    const char * literal, size_t literal_size);

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
extern(C) int
mailimap_uid_fetch(mailimap * session,
		   mailimap_set * set,
		   mailimap_fetch_type * fetch_type, clist ** result);

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
extern(C) int mailimap_authenticate(mailimap * session, const char * auth_type,
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
   @param result   The result is a clist of (uint *) and will be
   stored in (* result).
   
   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int
mailimap_search(mailimap * session, const char * charset,
    mailimap_search_key * key, clist ** result);

/*
   mailimap_uid_search()


   All mails that match the given criteria will be returned
   their unique identifiers in the result list.

   @param session  IMAP session
   @param charset  This indicates the charset of the strings that appears
   in the searching criteria
   @param key      This is the searching criteria
   @param result   The result is a clist of (uint *) and will be
   stored in (* result).
   
   @return the return code is one of MAILIMAP_ERROR_XXX or
     MAILIMAP_NO_ERROR codes
*/
extern(C) int mailimap_uid_search(mailimap * session, const char * charset,
    mailimap_search_key * key, clist ** result);

/*
   mailimap_search_result_free()

   This function will free the result of the a search.

   @param search_result   This is a clist of (uint *) returned
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
extern(C) int
mailimap_select(mailimap * session, const char * mb);

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
extern(C) int
mailimap_status(mailimap * session, const char * mb,
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
extern(C) int
mailimap_store(mailimap * session,
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
extern(C) int
mailimap_uid_store(mailimap * session,
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
extern(C) 
int mailimap_send_current_tag(mailimap * session);
extern(C) 
char * mailimap_read_line(mailimap * session);
extern(C) 
int mailimap_parse_response(mailimap * session,
    mailimap_response ** result);
extern(C) void mailimap_set_progress_callback(mailimap * session,
                                    mailprogress_function * body_progr_fun,
                                    mailprogress_function * items_progr_fun,
                                    void * context);

/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mailimap_helper.h,v 1.12 2006/06/07 15:10:01 smarinier Exp $
 */
extern(C) int mailimap_fetch_rfc822(mailimap * session,
			  uint msgid, char ** result);

extern(C) int mailimap_fetch_rfc822_header(mailimap * session,
				 uint msgid, char ** result);
extern(C) 
int mailimap_fetch_envelope(mailimap * session,
			    uint first, uint last,
			    clist ** result);
extern(C) 
int mailimap_append_simple(mailimap * session, const char * mailbox,
			   const char * content, uint size);
extern(C) 
int mailimap_login_simple(mailimap * session,
			  const char * userid, const char * password);

/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mailimap_socket.h,v 1.16 2006/12/26 13:13:24 hoa Exp $
 */

extern(C) int mailimap_socket_connect(mailimap * f, const char * server, uint16_t port);
extern(C) int mailimap_socket_starttls(mailimap * f);
extern(C) int mailimap_socket_starttls_with_callback(mailimap * f,
    void function(mailstream_ssl_context * ssl_context, void * data) callback
	, void * data);

/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mailimap_ssl.h,v 1.16 2006/12/26 13:13:24 hoa Exp $
 */

extern(C) int mailimap_ssl_connect(mailimap * f, const char * server, uint16_t port);
extern(C) int mailimap_ssl_connect_with_callback(mailimap * f, const char * server, uint16_t port,
    void function(mailstream_ssl_context * ssl_context, void * data) callback, void * data);

/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mailimap_types.h,v 1.34 2011/01/06 00:09:52 hoa Exp $
 */

/*
  IMAP4rev1 grammar

   address         = "(" addr-name SP addr-adl SP addr-mailbox SP
                     addr-host ")"

   addr-adl        = nstring
                       ; Holds route from [RFC-822] route-addr if
                       ; non-NIL

   addr-host       = nstring
                       ; NIL indicates [RFC-822] group syntax.
                       ; Otherwise, holds [RFC-822] domain name

   addr-mailbox    = nstring
                       ; NIL indicates end of [RFC-822] group; if
                       ; non-NIL and addr-host is NIL, holds
                       ; [RFC-822] group name.
                       ; Otherwise, holds [RFC-822] local-part
                       ; after removing [RFC-822] quoting



   addr-name       = nstring
                       ; If non-NIL, holds phrase from [RFC-822]
                       ; mailbox after removing [RFC-822] quoting

   append          = "APPEND" SP mailbox [SP flag-list] [SP date-time] SP
                     literal

   astring         = 1*ASTRING-CHAR / string

   ASTRING-CHAR   = ATOM-CHAR / resp-specials

   atom            = 1*ATOM-CHAR

   ATOM-CHAR       = <any CHAR except atom-specials>

   atom-specials   = "(" / ")" / "{" / SP / CTL / list-wildcards /
                     quoted-specials / resp-specials

   authenticate    = "AUTHENTICATE" SP auth-type *(CRLF base64)

   auth-type       = atom
                       ; Defined by [SASL]

   base64          = *(4base64-char) [base64-terminal]

   base64-char     = ALPHA / DIGIT / "+" / "/"
                       ; Case-sensitive

   base64-terminal = (2base64-char "==") / (3base64-char "=")

   body            = "(" (body-type-1part / body-type-mpart) ")"

   body-extension  = nstring / number /
                      "(" body-extension *(SP body-extension) ")"
                       ; Future expansion.  Client implementations
                       ; MUST accept body-extension fields.  Server
                       ; implementations MUST NOT generate
                       ; body-extension fields except as defined by
                       ; future standard or standards-track
                       ; revisions of this specification.

   body-ext-1part  = body-fld-md5 [SP body-fld-dsp [SP body-fld-lang
                     *(SP body-extension)]]
                       ; MUST NOT be returned on non-extensible
                       ; "BODY" fetch


   body-ext-mpart  = body-fld-param [SP body-fld-dsp [SP body-fld-lang
                     *(SP body-extension)]]
                       ; MUST NOT be returned on non-extensible
                       ; "BODY" fetch

   body-fields     = body-fld-param SP body-fld-id SP body-fld-desc SP
                     body-fld-enc SP body-fld-octets

   body-fld-desc   = nstring

   body-fld-dsp    = "(" string SP body-fld-param ")" / nil

   body-fld-enc    = (DQUOTE ("7BIT" / "8BIT" / "BINARY" / "BASE64"/
                     "QUOTED-PRINTABLE") DQUOTE) / string

   body-fld-id     = nstring

   body-fld-lang   = nstring / "(" string *(SP string) ")"

   body-fld-lines  = number

   body-fld-md5    = nstring

   body-fld-octets = number

   body-fld-param  = "(" string SP string *(SP string SP string) ")" / nil

   body-type-1part = (body-type-basic / body-type-msg / body-type-text)
                     [SP body-ext-1part]

   body-type-basic = media-basic SP body-fields
                       ; MESSAGE subtype MUST NOT be "RFC822"

   body-type-mpart = 1*body SP media-subtype
                     [SP body-ext-mpart]

   body-type-msg   = media-message SP body-fields SP envelope
                     SP body SP body-fld-lines

   body-type-text  = media-text SP body-fields SP body-fld-lines

   capability      = ("AUTH=" auth-type) / atom
                       ; New capabilities MUST begin with "X" or be
                       ; registered with IANA as standard or
                       ; standards-track


   capability-data = "CAPABILITY" *(SP capability) SP "IMAP4rev1"
                     *(SP capability)
                       ; IMAP4rev1 servers which offer RFC 1730
                       ; compatibility MUST list "IMAP4" as the first
                       ; capability.

   CHAR8           = %x01-ff
                       ; any OCTET except NUL, %x00

   command         = tag SP (command-any / command-auth / command-nonauth /
                     command-select) CRLF
                       ; Modal based on state

   command-any     = "CAPABILITY" / "LOGOUT" / "NOOP" / x-command
                       ; Valid in all states

   command-auth    = append / create / delete / examine / list / lsub /
                     rename / select / status / subscribe / unsubscribe
                       ; Valid only in Authenticated or Selected state

   command-nonauth = login / authenticate
                       ; Valid only when in Not Authenticated state

   command-select  = "CHECK" / "CLOSE" / "EXPUNGE" / copy / fetch / store /
                     uid / search
                       ; Valid only when in Selected state

   continue-req    = "+" SP (resp-text / base64) CRLF

   copy            = "COPY" SP set SP mailbox

   create          = "CREATE" SP mailbox
                       ; Use of INBOX gives a NO error

   date            = date-text / DQUOTE date-text DQUOTE

   date-day        = 1*2DIGIT
                       ; Day of month

   date-day-fixed  = (SP DIGIT) / 2DIGIT
                       ; Fixed-format version of date-day

   date-month      = "Jan" / "Feb" / "Mar" / "Apr" / "May" / "Jun" /
                     "Jul" / "Aug" / "Sep" / "Oct" / "Nov" / "Dec"

   date-text       = date-day "-" date-month "-" date-year

   date-year       = 4DIGIT

   date-time       = DQUOTE date-day-fixed "-" date-month "-" date-year
                     SP time SP zone DQUOTE

   delete          = "DELETE" SP mailbox
                       ; Use of INBOX gives a NO error

   digit-nz        = %x31-39
                       ; 1-9

   envelope        = "(" env-date SP env-subject SP env-from SP env-sender SP
                     env-reply-to SP env-to SP env-cc SP env-bcc SP
                     env-in-reply-to SP env-message-id ")"

   env-bcc         = "(" 1*address ")" / nil

   env-cc          = "(" 1*address ")" / nil

   env-date        = nstring

   env-from        = "(" 1*address ")" / nil

   env-in-reply-to = nstring

   env-message-id  = nstring

   env-reply-to    = "(" 1*address ")" / nil

   env-sender      = "(" 1*address ")" / nil

   env-subject     = nstring

   env-to          = "(" 1*address ")" / nil

   examine         = "EXAMINE" SP mailbox

   fetch           = "FETCH" SP set SP ("ALL" / "FULL" / "FAST" / fetch-att /
                     "(" fetch-att *(SP fetch-att) ")")

   fetch-att       = "ENVELOPE" / "FLAGS" / "INTERNALDATE" /
                     "RFC822" [".HEADER" / ".SIZE" / ".TEXT"] /
                     "BODY" ["STRUCTURE"] / "UID" /
                     "BODY" [".PEEK"] section ["<" number "." nz-number ">"]

   flag            = "\Answered" / "\Flagged" / "\Deleted" /
                     "\Seen" / "\Draft" / flag-keyword / flag-extension
                       ; Does not include "\Recent"

   flag-extension  = "\" atom
                       ; Future expansion.  Client implementations
                       ; MUST accept flag-extension flags.  Server
                       ; implementations MUST NOT generate
                       ; flag-extension flags except as defined by
                       ; future standard or standards-track
                       ; revisions of this specification.

   flag-fetch      = flag / "\Recent"

   flag-keyword    = atom

   flag-list       = "(" [flag *(SP flag)] ")"

   flag-perm       = flag / "\*"

   greeting        = "*" SP (resp-cond-auth / resp-cond-bye) CRLF

   header-fld-name = astring

   header-list     = "(" header-fld-name *(SP header-fld-name) ")"

   list            = "LIST" SP mailbox SP list-mailbox

   list-mailbox    = 1*list-char / string

   list-char       = ATOM-CHAR / list-wildcards / resp-specials

   list-wildcards  = "%" / "*"

   literal         = "{" number "}" CRLF *CHAR8
                       ; Number represents the number of CHAR8s

   login           = "LOGIN" SP userid SP password

   lsub            = "LSUB" SP mailbox SP list-mailbox

   mailbox         = "INBOX" / astring
                       ; INBOX is case-insensitive.  All case variants of
                       ; INBOX (e.g. "iNbOx") MUST be interpreted as INBOX
                       ; not as an astring.  An astring which consists of
                       ; the case-insensitive sequence "I" "N" "B" "O" "X"
                       ; is considered to be INBOX and not an astring.
                       ;  Refer to section 5.1 for further
                       ; semantic details of mailbox names.

   mailbox-data    =  "FLAGS" SP flag-list / "LIST" SP mailbox-list /
                      "LSUB" SP mailbox-list / "SEARCH" *(SP nz-number) /
                      "STATUS" SP mailbox SP "("
                      [status-att SP number *(SP status-att SP number)] ")" /
                      number SP "EXISTS" / number SP "RECENT"

   mailbox-list    = "(" [mbx-list-flags] ")" SP
                      (DQUOTE QUOTED-CHAR DQUOTE / nil) SP mailbox

   mbx-list-flags  = *(mbx-list-oflag SP) mbx-list-sflag
                     *(SP mbx-list-oflag) /
                     mbx-list-oflag *(SP mbx-list-oflag)

   mbx-list-oflag  = "\Noinferiors" / flag-extension
                       ; Other flags; multiple possible per LIST response

   mbx-list-sflag  = "\Noselect" / "\Marked" / "\Unmarked"
                       ; Selectability flags; only one per LIST response

   media-basic     = ((DQUOTE ("APPLICATION" / "AUDIO" / "IMAGE" / "MESSAGE" /
                     "VIDEO") DQUOTE) / string) SP media-subtype
                       ; Defined in [MIME-IMT]

   media-message   = DQUOTE "MESSAGE" DQUOTE SP DQUOTE "RFC822" DQUOTE
                       ; Defined in [MIME-IMT]

   media-subtype   = string
                       ; Defined in [MIME-IMT]

   media-text      = DQUOTE "TEXT" DQUOTE SP media-subtype
                       ; Defined in [MIME-IMT]

   message-data    = nz-number SP ("EXPUNGE" / ("FETCH" SP msg-att))

   msg-att         = "(" (msg-att-dynamic / msg-att-static)
                      *(SP (msg-att-dynamic / msg-att-static)) ")"

   msg-att-dynamic = "FLAGS" SP "(" [flag-fetch *(SP flag-fetch)] ")"
                       ; MAY change for a message

   msg-att-static  = "ENVELOPE" SP envelope / "INTERNALDATE" SP date-time /
                     "RFC822" [".HEADER" / ".TEXT"] SP nstring /
                     "RFC822.SIZE" SP number / "BODY" ["STRUCTURE"] SP body /
                     "BODY" section ["<" number ">"] SP nstring /
                     "UID" SP uniqueid
                       ; MUST NOT change for a message

   nil             = "NIL"

   nstring         = string / nil

   number          = 1*DIGIT
                       ; Unsigned 32-bit integer
                       ; (0 <= n < 4,294,967,296)

   nz-number       = digit-nz *DIGIT
                       ; Non-zero unsigned 32-bit integer
                       ; (0 < n < 4,294,967,296)

   password        = astring

   quoted          = DQUOTE *QUOTED-CHAR DQUOTE

   QUOTED-CHAR     = <any TEXT-CHAR except quoted-specials> /
                     "\" quoted-specials

   quoted-specials = DQUOTE / "\"

   rename          = "RENAME" SP mailbox SP mailbox
                       ; Use of INBOX as a destination gives a NO error

   response        = *(continue-req / response-data) response-done

   response-data   = "*" SP (resp-cond-state / resp-cond-bye /
                     mailbox-data / message-data / capability-data) CRLF

   response-done   = response-tagged / response-fatal

   response-fatal  = "*" SP resp-cond-bye CRLF
                       ; Server closes connection immediately

   response-tagged = tag SP resp-cond-state CRLF

   resp-cond-auth  = ("OK" / "PREAUTH") SP resp-text
                       ; Authentication condition

   resp-cond-bye   = "BYE" SP resp-text

   resp-cond-state = ("OK" / "NO" / "BAD") SP resp-text
                       ; Status condition

   resp-specials   = "]"

   resp-text       = ["[" resp-text-code "]" SP] text

   resp-text-code  = "ALERT" /
                     "BADCHARSET" [SP "(" astring *(SP astring) ")" ] /
                     capability-data / "PARSE" /
                     "PERMANENTFLAGS" SP "(" [flag-perm *(SP flag-perm)] ")" /
                     "READ-ONLY" / "READ-WRITE" / "TRYCREATE" /
                     "UIDNEXT" SP nz-number / "UIDVALIDITY" SP nz-number /
                     "UNSEEN" SP nz-number /
                     atom [SP 1*<any TEXT-CHAR except "]">]

   search          = "SEARCH" [SP "CHARSET" SP astring] 1*(SP search-key)
                       ; CHARSET argument to MUST be registered with IANA

   search-key      = "ALL" / "ANSWERED" / "BCC" SP astring /
                     "BEFORE" SP date / "BODY" SP astring /
                     "CC" SP astring / "DELETED" / "FLAGGED" /
                     "FROM" SP astring / "KEYWORD" SP flag-keyword / "NEW" /
                     "OLD" / "ON" SP date / "RECENT" / "SEEN" /
                     "SINCE" SP date / "SUBJECT" SP astring /
                     "TEXT" SP astring / "TO" SP astring /
                     "UNANSWERED" / "UNDELETED" / "UNFLAGGED" /
                     "UNKEYWORD" SP flag-keyword / "UNSEEN" /
                       ; Above this line were in [IMAP2]
                     "DRAFT" / "HEADER" SP header-fld-name SP astring /
                     "LARGER" SP number / "NOT" SP search-key /
                     "OR" SP search-key SP search-key /
                     "SENTBEFORE" SP date / "SENTON" SP date /
                     "SENTSINCE" SP date / "SMALLER" SP number /
                     "UID" SP set / "UNDRAFT" / set /
                     "(" search-key *(SP search-key) ")"

   section         = "[" [section-spec] "]"

   section-msgtext = "HEADER" / "HEADER.FIELDS" [".NOT"] SP header-list /
                     "TEXT"
                       ; top-level or MESSAGE/RFC822 part

   section-part    = nz-number *("." nz-number)
                       ; body part nesting

   section-spec    = section-msgtext / (section-part ["." section-text])

   section-text    = section-msgtext / "MIME"
                       ; text other than actual body part (headers, etc.)

   select          = "SELECT" SP mailbox

   sequence-num    = nz-number / "*"
                       ; * is the largest number in use.  For message
                       ; sequence numbers, it is the number of messages
                       ; in the mailbox.  For unique identifiers, it is
                       ; the unique identifier of the last message in
                       ; the mailbox.

   set             = sequence-num / (sequence-num ":" sequence-num) /
                     (set "," set)
                       ; Identifies a set of messages.  For message
                       ; sequence numbers, these are consecutive
                       ; numbers from 1 to the number of messages in
                       ; the mailbox
                       ; Comma delimits individual numbers, colon
                       ; delimits between two numbers inclusive.
                       ; Example: 2,4:7,9,12:* is 2,4,5,6,7,9,12,13,
                       ; 14,15 for a mailbox with 15 messages.


   status          = "STATUS" SP mailbox SP "(" status-att *(SP status-att) ")"

   status-att      = "MESSAGES" / "RECENT" / "UIDNEXT" / "UIDVALIDITY" /
                     "UNSEEN"

   store           = "STORE" SP set SP store-att-flags

   store-att-flags = (["+" / "-"] "FLAGS" [".SILENT"]) SP
                     (flag-list / (flag *(SP flag)))

   string          = quoted / literal

   subscribe       = "SUBSCRIBE" SP mailbox

   tag             = 1*<any ASTRING-CHAR except "+">

   text            = 1*TEXT-CHAR

   TEXT-CHAR       = <any CHAR except CR and LF>

   time            = 2DIGIT ":" 2DIGIT ":" 2DIGIT
                       ; Hours minutes seconds

   uid             = "UID" SP (copy / fetch / search / store)
                       ; Unique identifiers used instead of message
                       ; sequence numbers

   uniqueid        = nz-number
                       ; Strictly ascending

   unsubscribe     = "UNSUBSCRIBE" SP mailbox

   userid          = astring

   x-command       = "X" atom <experimental command arguments>

   zone            = ("+" / "-") 4DIGIT
                       ; Signed four-digit value of hhmm representing
                       ; hours and minutes east of Greenwich (that is,
                       ; the amount that the given time differs from
                       ; Universal Time).  Subtracting the timezone
                       ; from the given time will give the UT form.
                       ; The Universal Time zone is "+0000".
*/
/*
  IMPORTANT NOTE:
  
  All allocation functions will take as argument allocated data
  and will store these data in the structure they will allocate.
  Data should be persistant during all the use of the structure
  and will be freed by the free function of the structure

  allocation functions will return NULL on failure
*/


/*
  mailimap_address represents a mail address

  - personal_name is the name to display in an address
    '"name"' in '"name" <address@domain>', should be allocated
    with a malloc()
  
  - source_route is the source-route information in the
    mail address (RFC 822), should be allocated with a malloc()

  - mailbox_name is the name of the mailbox 'address' in
    '"name" <address@domain>', should be allocated with a malloc()

  - host_name is the name of the host 'domain' in
    '"name" <address@domain>', should be allocated with a malloc()

  if mailbox_name is not NULL and host_name is NULL, this is the name
  of a group, the next addresses in the list are elements of the group
  until we reach an address with a NULL mailbox_name.
*/

struct mailimap_address {
  char * ad_personal_name; /* can be NULL */
  char * ad_source_route;  /* can be NULL */
  char * ad_mailbox_name;  /* can be NULL */
  char * ad_host_name;     /* can be NULL */
}

extern(C) 
mailimap_address *
mailimap_address_new(char * ad_personal_name, char * ad_source_route,
		     char * ad_mailbox_name, char * ad_host_name);
extern(C) 
void mailimap_address_free(mailimap_address * addr);


/* this is the type of MIME body parsed by IMAP server */

enum {
  MAILIMAP_BODY_ERROR,
  MAILIMAP_BODY_1PART, /* single part */
  MAILIMAP_BODY_MPART  /* multi-part */
}

/*
  mailimap_body represent a MIME body parsed by IMAP server

  - type is the type of the MIME part (single part or multipart)

  - body_1part is defined if this is a single part

  - body_mpart is defined if this is a multipart
*/

extern(C) mailimap_body *
mailimap_body_new(int bd_type,
		  mailimap_body_type_1part * bd_body_1part,
		  mailimap_body_type_mpart * bd_body_mpart);
extern(C) 
void mailimap_body_free(mailimap_body * bodyd);



/*
  this is the type of MIME body extension
*/

enum {
  MAILIMAP_BODY_EXTENSION_ERROR,
  MAILIMAP_BODY_EXTENSION_NSTRING, /* string */
  MAILIMAP_BODY_EXTENSION_NUMBER,  /* number */
  MAILIMAP_BODY_EXTENSION_LIST     /* list of
                                      (struct mailimap_body_extension *) */
}

/*
  mailimap_body_extension is a future extension header field value

  - type is the type of the body extension (string, number or
    list of extension)

  - nstring is a string value if the type is string

  - number is a integer value if the type is number

  - list is a list of body extension if the type is a list
*/

struct mailimap_body_extension {
  int ext_type;
  /*
    can be MAILIMAP_BODY_EXTENSION_NSTRING, MAILIMAP_BODY_EXTENSION_NUMBER
    or MAILIMAP_BODY_EXTENSION_LIST
  */
  union ext_data_t {
    char * ext_nstring;    /* can be NULL */
    uint ext_number;
    clist * ext_body_extension_list;
    /* list of (struct mailimap_body_extension *) */
    /* can be NULL */
  }
 ext_data_t ext_data;
}
extern(C) mailimap_body_extension * mailimap_body_extension_new(int ext_type, 
	char * ext_nstring, uint ext_number, clist * ext_body_extension_list);

extern(C) 
void mailimap_body_extension_free(mailimap_body_extension * be);


/*
  mailimap_body_ext_1part is the extended result part of a single part
  bodystructure.
  
  - body_md5 is the value of the Content-MD5 header field, should be 
    allocated with malloc()

  - body_disposition is the value of the Content-Disposition header field

  - body_language is the value of the Content-Language header field
  
  - body_extension_list is the list of extension fields value.
*/

extern(C) mailimap_body_ext_1part *
mailimap_body_ext_1part_new(char * bd_md5, mailimap_body_fld_dsp * bd_disposition,
    mailimap_body_fld_lang * bd_language, char * bd_loc, clist * bd_extension_list);

extern(C) 
void mailimap_body_ext_1part_free(mailimap_body_ext_1part * body_ext_1part);


/*
  mailimap_body_ext_mpart is the extended result part of a multipart
  bodystructure.

  - body_parameter is the list of parameters of Content-Type header field
  
  - body_disposition is the value of Content-Disposition header field

  - body_language is the value of Content-Language header field

  - body_extension_list is the list of extension fields value.
*/

extern(C) mailimap_body_ext_mpart *
mailimap_body_ext_mpart_new(mailimap_body_fld_param * bd_parameter,
    mailimap_body_fld_dsp * bd_disposition, mailimap_body_fld_lang * bd_language,
    char * bd_loc, clist * bd_extension_list);

extern(C) void mailimap_body_ext_mpart_free(mailimap_body_ext_mpart * body_ext_mpart);


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

extern(C) mailimap_body_fields *
mailimap_body_fields_new(mailimap_body_fld_param * bd_parameter,
			 char * bd_id,
			 char * bd_description,
			 mailimap_body_fld_enc * bd_encoding,
			 uint bd_size);

extern(C) void mailimap_body_fields_free(mailimap_body_fields * body_fields);



/*
  mailimap_body_fld_dsp is the parsed value of the Content-Disposition field

  - disposition_type is the type of Content-Disposition
    (usually attachment or inline), should be allocated with malloc()

  - attributes is the list of Content-Disposition attributes
*/

extern(C) mailimap_body_fld_dsp * mailimap_body_fld_dsp_new(char * dsp_type,
    mailimap_body_fld_param * dsp_attributes);

extern(C) void mailimap_body_fld_dsp_free(mailimap_body_fld_dsp * bfd);


/* these are the different parsed values for Content-Transfer-Encoding */

enum {
  MAILIMAP_BODY_FLD_ENC_7BIT,             /* 7bit */
  MAILIMAP_BODY_FLD_ENC_8BIT,             /* 8bit */
  MAILIMAP_BODY_FLD_ENC_BINARY,           /* binary */
  MAILIMAP_BODY_FLD_ENC_BASE64,           /* base64 */
  MAILIMAP_BODY_FLD_ENC_QUOTED_PRINTABLE, /* quoted-printable */
  MAILIMAP_BODY_FLD_ENC_OTHER             /* other */
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

extern(C) 
mailimap_body_fld_enc *
mailimap_body_fld_enc_new(int enc_type, char * enc_value);
extern(C) 
void mailimap_body_fld_enc_free(mailimap_body_fld_enc * bfe);


/* this is the type of Content-Language header field value */

enum {
  MAILIMAP_BODY_FLD_LANG_ERROR,  /* error parse */
  MAILIMAP_BODY_FLD_LANG_SINGLE, /* single value */
  MAILIMAP_BODY_FLD_LANG_LIST    /* list of values */
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

extern(C) 
mailimap_body_fld_lang *
mailimap_body_fld_lang_new(int lg_type, char * lg_single, clist * lg_list);
extern(C) void
mailimap_body_fld_lang_free(mailimap_body_fld_lang * fld_lang);



/*
  mailimap_single_body_fld_param is a body field parameter
  
  - name is the name of the parameter, should be allocated with malloc()
  
  - value is the value of the parameter, should be allocated with malloc()
*/

struct mailimap_single_body_fld_param {
  char * pa_name;  /* != NULL */
  char * pa_value; /* != NULL */
}

extern(C) 
mailimap_single_body_fld_param *
mailimap_single_body_fld_param_new(char * pa_name, char * pa_value);

extern(C) 
void
mailimap_single_body_fld_param_free(mailimap_single_body_fld_param * p);


/*
  mailmap_body_fld_param is a list of parameters
  
  - list is the list of parameters.
*/

extern(C) 
mailimap_body_fld_param *
mailimap_body_fld_param_new(clist * pa_list);

extern(C) 
void
mailimap_body_fld_param_free(mailimap_body_fld_param * fld_param);


/*
  this is the kind of single part: a text part
  (when Content-Type is text/xxx), a message part (when Content-Type is
  message/rfc2822) or a basic part (others than multpart/xxx)
*/

enum {
  MAILIMAP_BODY_TYPE_1PART_ERROR, /* parse error */
  MAILIMAP_BODY_TYPE_1PART_BASIC, /* others then multipart/xxx */
  MAILIMAP_BODY_TYPE_1PART_MSG,   /* message/rfc2822 */
  MAILIMAP_BODY_TYPE_1PART_TEXT   /* text/xxx */
}


/*
  mailimap_body_type_1part is 

  - type is the kind of single part, this can be
  MAILIMAP_BODY_TYPE_1PART_BASIC, MAILIMAP_BODY_TYPE_1PART_MSG or
  MAILIMAP_BODY_TYPE_1PART_TEXT.

  - body_type_basic is the basic part when type is
    MAILIMAP_BODY_TYPE_1PART_BASIC

  - body_type_msg is the message part when type is
    MAILIMAP_BODY_TYPE_1PART_MSG
    
  - body_type_text is the text part when type is
    MAILIMAP_BODY_TYPE_1PART_TEXT
*/

extern(C) mailimap_body_type_1part *
mailimap_body_type_1part_new(int bd_type,
    mailimap_body_type_basic * bd_type_basic,
    mailimap_body_type_msg * bd_type_msg,
    mailimap_body_type_text * bd_type_text,
    mailimap_body_ext_1part * bd_ext_1part);

extern(C) void mailimap_body_type_1part_free(mailimap_body_type_1part * bt1p);



/*
  mailimap_body_type_basic is a basic field (with Content-Type other
  than multipart/xxx, message/rfc2822 and text/xxx

  - media_basic will be the MIME type of the part
  
  - body_fields will be the parsed fields of the MIME part
*/

extern(C) 
mailimap_body_type_basic *
mailimap_body_type_basic_new(mailimap_media_basic * bd_media_basic,
			     mailimap_body_fields * bd_fields);

extern(C) 
void mailimap_body_type_basic_free(mailimap_body_type_basic *
				   body_type_basic);

/*
  mailimap_body_type_mpart is a MIME multipart.

  - body_list is the list of sub-parts.

  - media_subtype is the subtype of the multipart (for example
    in multipart/alternative, this is "alternative")
    
  - body_ext_mpart is the extended fields of the MIME multipart
*/

extern(C) 
mailimap_body_type_mpart *
mailimap_body_type_mpart_new(clist * bd_list, char * bd_media_subtype,
    mailimap_body_ext_mpart * bd_ext_mpart);

extern(C) 
void mailimap_body_type_mpart_free(mailimap_body_type_mpart *
    body_type_mpart);

/*
  mailimap_body_type_msg is a MIME message part

  - body_fields is the MIME fields of the MIME message part

  - envelope is the list of parsed RFC 822 fields of the MIME message

  - body is the sub-part of the message

  - body_lines is the number of lines of the message part
*/

extern(C) 
mailimap_body_type_msg *
mailimap_body_type_msg_new(mailimap_body_fields * bd_fields,
			   mailimap_envelope * bd_envelope,
			   mailimap_body * bd_body,
			   uint bd_lines);

extern(C) void
mailimap_body_type_msg_free(mailimap_body_type_msg * body_type_msg);



/*
  mailimap_body_type_text is a single MIME part where Content-Type is text/xxx

  - media-text is the subtype of the text part (for example, in "text/plain",
    this is "plain", should be allocated with malloc()

  - body_fields is the MIME fields of the MIME message part

  - body_lines is the number of lines of the message part
*/

extern(C) 
mailimap_body_type_text *
mailimap_body_type_text_new(char * bd_media_text,
    mailimap_body_fields * bd_fields,
    uint bd_lines);

extern(C) void
mailimap_body_type_text_free(mailimap_body_type_text * body_type_text);



/* this is the type of capability field */

enum {
  MAILIMAP_CAPABILITY_AUTH_TYPE, /* when the capability is an
                                      authentication type */
  MAILIMAP_CAPABILITY_NAME       /* other type of capability */
}

/*
  mailimap_capability is a capability of the IMAP server

  - type is the type of capability, this is either a authentication type
    (MAILIMAP_CAPABILITY_AUTH_TYPE) or an other type of capability
    (MAILIMAP_CAPABILITY_NAME)

  - auth_type is a type of authentication "name" in "AUTH=name",
    auth_type can be for example "PLAIN", when this is an authentication type,
    should be allocated with malloc()

  - name is a type of capability when this is not an authentication type,
    should be allocated with malloc()
*/

extern(C) mailimap_capability *
mailimap_capability_new(int cap_type, char * cap_auth_type, char * cap_name);

extern(C) 
void mailimap_capability_free(mailimap_capability * c);




/*
  mailimap_capability_data is a list of capability

  - list is the list of capability
*/


extern(C) 
mailimap_capability_data * mailimap_capability_data_new(clist * cap_list);
extern(C) void
mailimap_capability_data_free(mailimap_capability_data * cap_data);



/* this is the type of continue request data */

enum {
  MAILIMAP_CONTINUE_REQ_ERROR,  /* on parse error */ 
  MAILIMAP_CONTINUE_REQ_TEXT,   /* when data is a text response */
  MAILIMAP_CONTINUE_REQ_BASE64  /* when data is a base64 response */
}

/*
  mailimap_continue_req is a continue request (a response prefixed by "+")

  - type is the type of continue request response
    MAILIMAP_CONTINUE_REQ_TEXT (when information data is text),
    MAILIMAP_CONTINUE_REQ_BASE64 (when information data is base64)
  
  - text is the information of type text in case of text data

  - base64 is base64 encoded data in the other case, should be allocated
    with malloc()
*/

struct mailimap_continue_req {
  int cr_type;
  union cr_data_t {
    mailimap_resp_text * cr_text; /* can be NULL */
    char * cr_base64;                    /* can be NULL */
  } 
  cr_data_t cr_data;
}

extern(C) 
mailimap_continue_req *
mailimap_continue_req_new(int cr_type, mailimap_resp_text * cr_text,
			  char * cr_base64);
extern(C) 
void mailimap_continue_req_free(mailimap_continue_req * cont_req);


/*
  mailimap_date_time is a date
  
  - day is the day of month (1 to 31)

  - month (1 to 12)

  - year (4 digits)

  - hour (0 to 23)
  
  - min (0 to 59)

  - sec (0 to 59)

  - zone (this is the decimal value that we can read, for example:
    for "-0200", the value is -200)
*/

extern(C) mailimap_date_time *
mailimap_date_time_new(int dt_day, int dt_month, int dt_year, int dt_hour,
		       int dt_min, int dt_sec, int dt_zone);

extern(C) 
void mailimap_date_time_free(mailimap_date_time * date_time);



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

extern(C) 
mailimap_envelope *
mailimap_envelope_new(char * env_date, char * env_subject,
		      mailimap_env_from * env_from,
		      mailimap_env_sender * env_sender,
		      mailimap_env_reply_to * env_reply_to,
		      mailimap_env_to * env_to,
		      mailimap_env_cc* env_cc,
		      mailimap_env_bcc * env_bcc,
		      char * env_in_reply_to, char * env_message_id);
extern(C) 
void mailimap_envelope_free(mailimap_envelope * env);




/* this is the type of flag */

enum {
  MAILIMAP_FLAG_ANSWERED,  /* \Answered flag */
  MAILIMAP_FLAG_FLAGGED,   /* \Flagged flag */
  MAILIMAP_FLAG_DELETED,   /* \Deleted flag */
  MAILIMAP_FLAG_SEEN,      /* \Seen flag */
  MAILIMAP_FLAG_DRAFT,     /* \Draft flag */
  MAILIMAP_FLAG_KEYWORD,   /* keyword flag */
  MAILIMAP_FLAG_EXTENSION  /* \extension flag */
}


/*
  mailimap_flag is a message flag (that we can associate with a message)
  
  - type is the type of the flag, MAILIMAP_FLAG_XXX

  - keyword is the flag when the flag is of keyword type,
    should be allocated with malloc()
  
  - extension is the flag when the flag is of extension type, should be
    allocated with malloc()
*/

struct mailimap_flag {
  int fl_type;
  union fl_data_t {
    char * fl_keyword;   /* can be NULL */
    char * fl_extension; /* can be NULL */
  } 
  fl_data_t fl_data;
}
extern(C) mailimap_flag * mailimap_flag_new(int fl_type,
    char * fl_keyword, char * fl_extension);
extern(C) void mailimap_flag_free(mailimap_flag * f);




/* this is the type of flag */

enum {
  MAILIMAP_FLAG_FETCH_ERROR,  /* on parse error */
  MAILIMAP_FLAG_FETCH_RECENT, /* \Recent flag */
  MAILIMAP_FLAG_FETCH_OTHER   /* other type of flag */
}

/*
  mailimap_flag_fetch is a message flag (when we fetch it)

  - type is the type of flag fetch
  
  - flag is the flag when this is not a \Recent flag
*/

struct mailimap_flag_fetch {
  int fl_type;
  mailimap_flag * fl_flag; /* can be NULL */
}
extern(C) 
mailimap_flag_fetch *
mailimap_flag_fetch_new(int fl_type, mailimap_flag * fl_flag);
extern(C) 
void mailimap_flag_fetch_free(mailimap_flag_fetch * flag_fetch);




/* this is the type of flag */

enum {
  MAILIMAP_FLAG_PERM_ERROR, /* on parse error */
  MAILIMAP_FLAG_PERM_FLAG,  /* to specify that usual flags can be changed */
  MAILIMAP_FLAG_PERM_ALL    /* to specify that new flags can be created */
}


/*
  mailimap_flag_perm is a flag returned in case of PERMANENTFLAGS response
  
  - type is the type of returned PERMANENTFLAGS, it can be
    MAILIMAP_FLAG_PERM_FLAG (the given flag can be changed permanently) or
    MAILIMAP_FLAG_PERM_ALL (new flags can be created)
  
  - flag is the given flag when type is MAILIMAP_FLAG_PERM_FLAG
*/

struct mailimap_flag_perm {
  int fl_type;
  mailimap_flag * fl_flag; /* can be NULL */
}
extern(C) 
mailimap_flag_perm *
mailimap_flag_perm_new(int fl_type, mailimap_flag * fl_flag);
extern(C) 
void mailimap_flag_perm_free(mailimap_flag_perm * flag_perm);


/*
  mailimap_flag_list is a list of flags
  
  - list is a list of flags
*/

extern(C) mailimap_flag_list *
mailimap_flag_list_new(clist * fl_list);
extern(C) void mailimap_flag_list_free(mailimap_flag_list * flag_list);




/* this is the type of greeting response */

enum {
  MAILIMAP_GREETING_RESP_COND_ERROR, /* on parse error */
  MAILIMAP_GREETING_RESP_COND_AUTH,  /* when connection is accepted */
  MAILIMAP_GREETING_RESP_COND_BYE    /* when connection is refused */
}

/*
  mailimap_greeting is the response returned on connection

  - type is the type of response on connection, either
  MAILIMAP_GREETING_RESP_COND_AUTH if connection is accepted or
  MAIMIMAP_GREETING_RESP_COND_BYE if connection is refused
*/

struct mailimap_greeting {
  int gr_type;
  union gr_data_t {
    mailimap_resp_cond_auth * gr_auth; /* can be NULL */
    mailimap_resp_cond_bye * gr_bye;   /* can be NULL */
  } 
  gr_data_t gr_data;
}
extern(C) 
mailimap_greeting *
mailimap_greeting_new(int gr_type,
    mailimap_resp_cond_auth * gr_auth,
    mailimap_resp_cond_bye * gr_bye);
extern(C) 
void mailimap_greeting_free(mailimap_greeting * greeting);


/*
  mailimap_header_list is a list of headers that can be specified when
  we want to fetch fields

  - list is a list of header names, each header name should be allocated
    with malloc()
*/

extern(C) 
mailimap_header_list *
mailimap_header_list_new(clist * hdr_list);
extern(C) 
void
mailimap_header_list_free(mailimap_header_list * header_list);



/* this is the type of mailbox STATUS that can be returned */

enum {
  MAILIMAP_STATUS_ATT_MESSAGES,    /* when requesting the number of
                                      messages */
  MAILIMAP_STATUS_ATT_RECENT,      /* when requesting the number of
                                      recent messages */
  MAILIMAP_STATUS_ATT_UIDNEXT,     /* when requesting the next unique
                                      identifier */
  MAILIMAP_STATUS_ATT_UIDVALIDITY, /* when requesting the validity of
                                      message unique identifiers*/
  MAILIMAP_STATUS_ATT_UNSEEN       /* when requesting the number of
                                      unseen messages */
}

/*
  mailimap_status_info is a returned information when a STATUS of 
  a mailbox is requested

  - att is the type of mailbox STATUS, the value can be 
    MAILIMAP_STATUS_ATT_MESSAGES, MAILIMAP_STATUS_ATT_RECENT,
    MAILIMAP_STATUS_ATT_UIDNEXT, MAILIMAP_STATUS_ATT_UIDVALIDITY or
    MAILIMAP_STATUS_ATT_UNSEEN

  - value is the value of the given information
*/

struct mailimap_status_info {
  int st_att;
  uint st_value;
}
extern(C) 
mailimap_status_info *
mailimap_status_info_new(int st_att, uint st_value);
extern(C) 
void mailimap_status_info_free(mailimap_status_info * info);



/*
  mailimap_mailbox_data_status is the list of information returned
  when a STATUS of a mailbox is requested

  - mailbox is the name of the mailbox, should be allocated with malloc()
  
  - status_info_list is the list of information returned
*/

extern(C) 
mailimap_mailbox_data_status *
mailimap_mailbox_data_status_new(char * st_mailbox,
    clist * st_info_list);
extern(C) 
void
mailimap_mailbox_data_status_free(mailimap_mailbox_data_status * info);



/* this is the type of mailbox information that is returned */

enum {
  MAILIMAP_MAILBOX_DATA_ERROR,  /* on parse error */
  MAILIMAP_MAILBOX_DATA_FLAGS,  /* flag that are applicable to the mailbox */
  MAILIMAP_MAILBOX_DATA_LIST,   /* this is a mailbox in the list of mailboxes
                                   returned on LIST command*/
  MAILIMAP_MAILBOX_DATA_LSUB,   /* this is a mailbox in the list of
                                   subscribed mailboxes returned on LSUB
                                   command */
  MAILIMAP_MAILBOX_DATA_SEARCH, /* this is a list of messages numbers or
                                   unique identifiers returned
                                   on a SEARCH command*/
  MAILIMAP_MAILBOX_DATA_STATUS, /* this is the list of information returned
                                   on a STATUS command */
  MAILIMAP_MAILBOX_DATA_EXISTS, /* this is the number of messages in the
                                   mailbox */
  MAILIMAP_MAILBOX_DATA_RECENT, /* this is the number of recent messages
                                   in the mailbox */
  MAILIMAP_MAILBOX_DATA_EXTENSION_DATA  /* this mailbox-data stores data
                                           returned by an extension */
}

/*
  mailimap_mailbox_data is an information related to a mailbox
  
  - type is the type of mailbox_data that is filled, the value of this field
    can be MAILIMAP_MAILBOX_DATA_FLAGS, MAILIMAP_MAILBOX_DATA_LIST,
    MAILIMAP_MAILBOX_DATA_LSUB, MAILIMAP_MAILBOX_DATA_SEARCH,
    MAILIMAP_MAILBOX_DATA_STATUS, MAILIMAP_MAILBOX_DATA_EXISTS
    or MAILIMAP_MAILBOX_DATA_RECENT.

  - flags is the flags that are applicable to the mailbox when
    type is MAILIMAP_MAILBOX_DATA_FLAGS

  - list is a mailbox in the list of mailboxes returned on LIST command
    when type is MAILIMAP_MAILBOX_DATA_LIST

  - lsub is a mailbox in the list of subscribed mailboxes returned on
    LSUB command when type is MAILIMAP_MAILBOX_DATA_LSUB

  - search is a list of messages numbers or unique identifiers returned
    on SEARCH command when type MAILIMAP_MAILBOX_DATA_SEARCH, each element
    should be allocated with malloc()

  - status is a list of information returned on STATUS command when
    type is MAILIMAP_MAILBOX_DATA_STATUS

  - exists is the number of messages in the mailbox when type
    is MAILIMAP_MAILBOX_DATA_EXISTS

  - recent is the number of recent messages in the mailbox when type
    is MAILIMAP_MAILBOX_DATA_RECENT
*/

struct mailimap_mailbox_data {
  int mbd_type;
  union mbd_data_t {
    mailimap_flag_list * mbd_flags;   /* can be NULL */
    mailimap_mailbox_list * mbd_list; /* can be NULL */
    mailimap_mailbox_list * mbd_lsub; /* can be NULL */
    clist * mbd_search;  /* list of nz-number (uint *), can be NULL */
    mailimap_mailbox_data_status *  mbd_status; /* can be NULL */
    uint mbd_exists;
    uint mbd_recent;
    mailimap_extension_data * mbd_extension; /* can be NULL */
  } 
  mbd_data_t mbd_data;
}
extern(C) 
mailimap_mailbox_data *
mailimap_mailbox_data_new(int mbd_type, mailimap_flag_list * mbd_flags,
    mailimap_mailbox_list * mbd_list,
    mailimap_mailbox_list * mbd_lsub,
    clist * mbd_search,
    mailimap_mailbox_data_status * mbd_status,
    uint mbd_exists,
    uint mbd_recent,
    mailimap_extension_data * mbd_extension);

extern(C) 
void
mailimap_mailbox_data_free(mailimap_mailbox_data * mb_data);



/* this is the type of mailbox flags */

enum {
  MAILIMAP_MBX_LIST_FLAGS_SFLAG,    /* mailbox single flag - a flag in
                                       {\NoSelect, \Marked, \Unmarked} */
  MAILIMAP_MBX_LIST_FLAGS_NO_SFLAG  /* mailbox other flag -  mailbox flag
                                       other than \NoSelect \Marked and
                                       \Unmarked) */
}

/* this is a single flag type */

enum {
  MAILIMAP_MBX_LIST_SFLAG_ERROR,
  MAILIMAP_MBX_LIST_SFLAG_MARKED,
  MAILIMAP_MBX_LIST_SFLAG_NOSELECT,
  MAILIMAP_MBX_LIST_SFLAG_UNMARKED
}

/*
  mailimap_mbx_list_flags is a mailbox flag

  - type is the type of mailbox flag, it can be MAILIMAP_MBX_LIST_FLAGS_SFLAG,
    or MAILIMAP_MBX_LIST_FLAGS_NO_SFLAG.

  - oflags is a list of "mailbox other flag"
  
  - sflag is a mailbox single flag
*/

struct mailimap_mbx_list_flags {
  int mbf_type;
  clist * mbf_oflags; /* list of
                         (struct mailimap_mbx_list_oflag *), != NULL */
  int mbf_sflag;
}
extern(C) 
mailimap_mbx_list_flags *
mailimap_mbx_list_flags_new(int mbf_type,
    clist * mbf_oflags, int mbf_sflag);
extern(C) 
void
mailimap_mbx_list_flags_free(mailimap_mbx_list_flags * mbx_list_flags);



/* this is the type of the mailbox other flag */

enum {
  MAILIMAP_MBX_LIST_OFLAG_ERROR,       /* on parse error */
  MAILIMAP_MBX_LIST_OFLAG_NOINFERIORS, /* \NoInferior flag */
  MAILIMAP_MBX_LIST_OFLAG_FLAG_EXT     /* other flag */
}

/*
  mailimap_mbx_list_oflag is a mailbox other flag

  - type can be MAILIMAP_MBX_LIST_OFLAG_NOINFERIORS when this is 
    a \NoInferior flag or MAILIMAP_MBX_LIST_OFLAG_FLAG_EXT

  - flag_ext is set when MAILIMAP_MBX_LIST_OFLAG_FLAG_EXT and is
    an extension flag, should be allocated with malloc()
*/

struct mailimap_mbx_list_oflag {
  int of_type;
  char * of_flag_ext; /* can be NULL */
}
extern(C) 
mailimap_mbx_list_oflag *
mailimap_mbx_list_oflag_new(int of_type, char * of_flag_ext);
extern(C) 
void
mailimap_mbx_list_oflag_free(mailimap_mbx_list_oflag * oflag);



/*
  mailimap_mailbox_list is a list of mailbox flags

  - mb_flag is a list of mailbox flags

  - delimiter is the delimiter of the mailbox path

  - mb is the name of the mailbox, should be allocated with malloc()
*/

struct mailimap_mailbox_list {
  mailimap_mbx_list_flags * mb_flag; /* can be NULL */
  char mb_delimiter;
  char * mb_name; /* != NULL */
}
extern(C) 
mailimap_mailbox_list *
mailimap_mailbox_list_new(mailimap_mbx_list_flags * mbx_flags,
    char mb_delimiter, char * mb_name);
extern(C) 
void
mailimap_mailbox_list_free(mailimap_mailbox_list * mb_list);



/* this is the MIME type */

enum {
  MAILIMAP_MEDIA_BASIC_APPLICATION, /* application/xxx */
  MAILIMAP_MEDIA_BASIC_AUDIO,       /* audio/xxx */
  MAILIMAP_MEDIA_BASIC_IMAGE,       /* image/xxx */
  MAILIMAP_MEDIA_BASIC_MESSAGE,     /* message/xxx */
  MAILIMAP_MEDIA_BASIC_VIDEO,       /* video/xxx */
  MAILIMAP_MEDIA_BASIC_OTHER        /* for all other cases */
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

extern(C) 
mailimap_media_basic *
mailimap_media_basic_new(int med_type,
    char * med_basic_type, char * med_subtype);

void
mailimap_media_basic_free(mailimap_media_basic * media_basic);



/* this is the type of message data */

enum {
  MAILIMAP_MESSAGE_DATA_ERROR,
  MAILIMAP_MESSAGE_DATA_EXPUNGE,
  MAILIMAP_MESSAGE_DATA_FETCH
}

/*
  mailimap_message_data is an information related to a message

  - number is the number or the unique identifier of the message
  
  - type is the type of information, this value can be
    MAILIMAP_MESSAGE_DATA_EXPUNGE or MAILIMAP_MESSAGE_DATA_FETCH
    
  - msg_att is the message data
*/

struct mailimap_message_data {
  uint mdt_number;
  int mdt_type;
  mailimap_msg_att * mdt_msg_att; /* can be NULL */
                                     /* if type = EXPUNGE, can be NULL */
}
extern(C) 
mailimap_message_data *
mailimap_message_data_new(uint mdt_number, int mdt_type,
    mailimap_msg_att * mdt_msg_att);
extern(C) 
void
mailimap_message_data_free(mailimap_message_data * msg_data);


/*
  mailimap_msg_att_item is a message attribute

  - type is the type of message attribute, the value can be
    MAILIMAP_MSG_ATT_ITEM_DYNAMIC or MAILIMAP_MSG_ATT_ITEM_STATIC
  
  - msg_att_dyn is a dynamic message attribute when type is
    MAILIMAP_MSG_ATT_ITEM_DYNAMIC

  - msg_att_static is a static message attribute when type is
    MAILIMAP_MSG_ATT_ITEM_STATIC
*/

extern(C) 
mailimap_msg_att_item *
mailimap_msg_att_item_new(int att_type,
    mailimap_msg_att_dynamic * att_dyn,
    mailimap_msg_att_static * att_static);
extern(C) 
void
mailimap_msg_att_item_free(mailimap_msg_att_item * item);


/*
  mailimap_msg_att is a list of attributes
  
  - list is a list of message attributes

  - number is the message number or unique identifier, this field
    has been added for implementation purpose
*/

extern(C) 
mailimap_msg_att * mailimap_msg_att_new(clist * att_list);
extern(C) 
void mailimap_msg_att_free(mailimap_msg_att * msg_att);


/*
  mailimap_msg_att_dynamic is a dynamic message attribute
  
  - list is a list of flags (that have been fetched)
*/

extern(C) 
mailimap_msg_att_dynamic *
mailimap_msg_att_dynamic_new(clist * att_list);
extern(C) 
void
mailimap_msg_att_dynamic_free(mailimap_msg_att_dynamic * msg_att_dyn);



/*
  mailimap_msg_att_body_section is a MIME part content
  
  - section is the location of the MIME part in the message
  
  - origin_octet is the offset of the requested part of the MIME part
  
  - body_part is the content or partial content of the MIME part,
    should be allocated through a MMAPString

  - length is the size of the content
*/

extern(C) mailimap_msg_att_body_section *
mailimap_msg_att_body_section_new(mailimap_section * section,
    uint sec_origin_octet,
    char * sec_body_part,
    size_t sec_length);
extern(C) 
void
mailimap_msg_att_body_section_free(mailimap_msg_att_body_section * 
    msg_att_body_section);



/*
  this is the type of static message attribute
*/

/*
  mailimap_msg_att_static is a given part of the message
  
  - type is the type of the static message attribute, the value can be 
    MAILIMAP_MSG_ATT_ENVELOPE, MAILIMAP_MSG_ATT_INTERNALDATE,
    MAILIMAP_MSG_ATT_RFC822, MAILIMAP_MSG_ATT_RFC822_HEADER,
    MAILIMAP_MSG_ATT_RFC822_TEXT, MAILIMAP_MSG_ATT_RFC822_SIZE,
    MAILIMAP_MSG_ATT_BODY, MAILIMAP_MSG_ATT_BODYSTRUCTURE,
    MAILIMAP_MSG_ATT_BODY_SECTION, MAILIMAP_MSG_ATT_UID

  - env is the headers parsed by the server if type is
    MAILIMAP_MSG_ATT_ENVELOPE

  - internal_date is the date of message kept by the server if type is
    MAILIMAP_MSG_ATT_INTERNALDATE

  - rfc822 is the message content if type is MAILIMAP_MSG_ATT_RFC822,
    should be allocated through a MMAPString

  - rfc822_header is the message header if type is
    MAILIMAP_MSG_ATT_RFC822_HEADER, should be allocated through a MMAPString

  - rfc822_text is the message text part if type is
    MAILIMAP_MSG_ATT_RFC822_TEXT, should be allocated through a MMAPString

  - rfc822_size is the message size if type is MAILIMAP_MSG_ATT_SIZE

  - body is the MIME description of the message

  - bodystructure is the MIME description of the message with additional
    information

  - body_section is a MIME part content

  - uid is a unique message identifier
*/

extern(C) 
mailimap_msg_att_static *
mailimap_msg_att_static_new(int att_type, mailimap_envelope * att_env,
    mailimap_date_time * att_internal_date,
    char * att_rfc822,
    char * att_rfc822_header,
    char * att_rfc822_text,
    size_t att_length,
    uint att_rfc822_size,
    mailimap_body * att_bodystructure,
    mailimap_body * att_body,
    mailimap_msg_att_body_section * att_body_section,
    uint att_uid);
extern(C) 
void
mailimap_msg_att_static_free(mailimap_msg_att_static * item);



/* this is the type of a response element */

enum {
  MAILIMAP_RESP_ERROR,     /* on parse error */
  MAILIMAP_RESP_CONT_REQ,  /* continuation request */
  MAILIMAP_RESP_RESP_DATA  /* response data */
}

/*
  mailimap_cont_req_or_resp_data is a response element
  
  - type is the type of response, the value can be MAILIMAP_RESP_CONT_REQ
    or MAILIMAP_RESP_RESP_DATA

  - cont_req is a continuation request

  - resp_data is a reponse data
*/

struct mailimap_cont_req_or_resp_data {
  int rsp_type;
  union rsp_data_t {
    mailimap_continue_req * rsp_cont_req;   /* can be NULL */
    mailimap_response_data * rsp_resp_data; /* can be NULL */
  } 
  rsp_data_t rsp_data;
}

extern(C) mailimap_cont_req_or_resp_data *
mailimap_cont_req_or_resp_data_new(int rsp_type,
    mailimap_continue_req * rsp_cont_req,
    mailimap_response_data * rsp_resp_data);
extern(C) 
void
mailimap_cont_req_or_resp_data_free(mailimap_cont_req_or_resp_data *
				    cont_req_or_resp_data);


/*
  mailimap_response is a list of response elements

  - cont_req_or_resp_data_list is a list of response elements

  - resp_done is an ending response element
*/

extern(C) mailimap_response *
mailimap_response_new(clist * rsp_cont_req_or_resp_data_list,
    mailimap_response_done * rsp_resp_done);
extern(C) 
void
mailimap_response_free(mailimap_response * resp);



/* this is the type of an untagged response */

enum {
  MAILIMAP_RESP_DATA_TYPE_ERROR,           /* on parse error */
  MAILIMAP_RESP_DATA_TYPE_COND_STATE,      /* condition state response */
  MAILIMAP_RESP_DATA_TYPE_COND_BYE,        /* BYE response (server is about
                                              to close the connection) */
  MAILIMAP_RESP_DATA_TYPE_MAILBOX_DATA,    /* response related to a mailbox */
  MAILIMAP_RESP_DATA_TYPE_MESSAGE_DATA,    /* response related to a message */
  MAILIMAP_RESP_DATA_TYPE_CAPABILITY_DATA, /* capability information */
  MAILIMAP_RESP_DATA_TYPE_EXTENSION_DATA   /* data parsed by extension */
}

/*
  mailimap_reponse_data is an untagged response

  - type is the type of the untagged response, it can be
    MAILIMAP_RESP_DATA_COND_STATE, MAILIMAP_RESP_DATA_COND_BYE,
    MAILIMAP_RESP_DATA_MAILBOX_DATA, MAILIMAP_RESP_DATA_MESSAGE_DATA
    or MAILIMAP_RESP_DATA_CAPABILITY_DATA

  - cond_state is a condition state response

  - bye is a BYE response (server is about to close the connection)
  
  - mailbox_data is a response related to a mailbox

  - message_data is a response related to a message

  - capability is information about capabilities
*/

struct mailimap_response_data {
  int rsp_type;
  union rsp_data_t {
    mailimap_resp_cond_state * rsp_cond_state;      /* can be NULL */
    mailimap_resp_cond_bye * rsp_bye;               /* can be NULL */
    mailimap_mailbox_data * rsp_mailbox_data;       /* can be NULL */
    mailimap_message_data * rsp_message_data;       /* can be NULL */
    mailimap_capability_data * rsp_capability_data; /* can be NULL */
    mailimap_extension_data * rsp_extension_data;   /* can be NULL */
  } 
  rsp_data_t rsp_data;
}
extern(C) 
mailimap_response_data *
mailimap_response_data_new(int rsp_type,
    mailimap_resp_cond_state * rsp_cond_state,
    mailimap_resp_cond_bye * rsp_bye,
    mailimap_mailbox_data * rsp_mailbox_data,
    mailimap_message_data * rsp_message_data,
    mailimap_capability_data * rsp_capability_data,
    mailimap_extension_data * rsp_extension_data);
extern(C) 
void
mailimap_response_data_free(mailimap_response_data * resp_data);



/* this is the type of an ending response */

/*
  mailimap_response_done is an ending response

  - type is the type of the ending response

  - tagged is a tagged response

  - fatal is a fatal error response
*/

extern(C) 
mailimap_response_done *
mailimap_response_done_new(int rsp_type,
    mailimap_response_tagged * rsp_tagged,
    mailimap_response_fatal * rsp_fatal);
extern(C) 
void mailimap_response_done_free(mailimap_response_done *
				 resp_done);


/*
  mailimap_response_fatal is a fatal error response

  - bye is a BYE response text
*/

extern(C) 
mailimap_response_fatal *
mailimap_response_fatal_new(mailimap_resp_cond_bye * rsp_bye);
extern(C)
void mailimap_response_fatal_free(mailimap_response_fatal * resp_fatal);



/*
  mailimap_response_tagged is a tagged response

  - tag is the sent tag, should be allocated with malloc()

  - cond_state is a condition state response
*/

extern(C)
mailimap_response_tagged *
mailimap_response_tagged_new(char * rsp_tag,
    mailimap_resp_cond_state * rsp_cond_state);
extern(C)
void
mailimap_response_tagged_free(mailimap_response_tagged * tagged);


/* this is the type of an authentication condition response */

/*
  mailimap_resp_cond_auth is an authentication condition response

  - type is the type of the authentication condition response,
    the value can be MAILIMAP_RESP_COND_AUTH_OK or
    MAILIMAP_RESP_COND_AUTH_PREAUTH

  - text is a text response
*/

extern(C)
mailimap_resp_cond_auth *
mailimap_resp_cond_auth_new(int rsp_type,
    mailimap_resp_text * rsp_text);
extern(C)
void
mailimap_resp_cond_auth_free(mailimap_resp_cond_auth * cond_auth);



/*
  mailimap_resp_cond_bye is a BYE response

  - text is a text response
*/

extern(C)
mailimap_resp_cond_bye *
mailimap_resp_cond_bye_new(mailimap_resp_text * rsp_text);
extern(C)
void
mailimap_resp_cond_bye_free(mailimap_resp_cond_bye * cond_bye);



/* this is the type of a condition state response */

/*
  mailimap_resp_cond_state is a condition state reponse
  
  - type is the type of the condition state response

  - text is a text response
*/

extern(C)
mailimap_resp_cond_state *
mailimap_resp_cond_state_new(int rsp_type,
    mailimap_resp_text * rsp_text);
extern(C)
void
mailimap_resp_cond_state_free(mailimap_resp_cond_state * cond_state);



/*
  mailimap_resp_text is a text response

  - resp_code is a response code
  
  - text is a human readable text, should be allocated with malloc()
*/

extern(C)mailimap_resp_text *
mailimap_resp_text_new(mailimap_resp_text_code * resp_code,
		       char * rsp_text);
extern(C)
void mailimap_resp_text_free(mailimap_resp_text * resp_text);



/* this is the type of the response code */

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

/*
  mailimap_section is a MIME part section identifier

  section_spec is the MIME section identifier
*/

extern(C)
mailimap_section *
mailimap_section_new(mailimap_section_spec * sec_spec);
extern(C)
void mailimap_section_free(mailimap_section * section);


/* this is the type of the message/rfc822 part description */

enum {
  MAILIMAP_SECTION_MSGTEXT_HEADER,            /* header fields part of the
                                                 message */
  MAILIMAP_SECTION_MSGTEXT_HEADER_FIELDS,     /* given header fields of the
                                                 message */
  MAILIMAP_SECTION_MSGTEXT_HEADER_FIELDS_NOT, /* header fields of the
                                                 message except the given */
  MAILIMAP_SECTION_MSGTEXT_TEXT               /* text part  */
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

extern(C)
mailimap_section_msgtext *
mailimap_section_msgtext_new(int sec_type,
    mailimap_header_list * sec_header_list);
extern(C) void mailimap_section_msgtext_free(mailimap_section_msgtext * msgtext);



/*
  mailimap_section_part is the MIME part location in a message
  
  - section_id is a list of number index of the sub-part in the mail structure,
    each element should be allocated with malloc()

*/

extern(C)
mailimap_section_part *
mailimap_section_part_new(clist * sec_id);
extern(C)
void
mailimap_section_part_free(mailimap_section_part * section_part);



/* this is the type of section specification */

enum {
  MAILIMAP_SECTION_SPEC_SECTION_MSGTEXT, /* if requesting data of the root
                                            MIME message/rfc822 part */
  MAILIMAP_SECTION_SPEC_SECTION_PART     /* location of the MIME part
                                            in the message */
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

extern(C)
mailimap_section_spec *
mailimap_section_spec_new(int sec_type,
    mailimap_section_msgtext * sec_msgtext,
    mailimap_section_part * sec_part,
    mailimap_section_text * sec_text);
extern(C)
void
mailimap_section_spec_free(mailimap_section_spec * section_spec);



/* this is the type of body part location for a given MIME part */

enum {
  MAILIMAP_SECTION_TEXT_ERROR,           /* on parse error **/
  MAILIMAP_SECTION_TEXT_SECTION_MSGTEXT, /* if the MIME type is
                                            message/rfc822, headers or text
                                            can be requested */
  MAILIMAP_SECTION_TEXT_MIME             /* for all MIME types,
                                            MIME headers can be requested */
}

/*
  mailimap_section_text is the body part location for a given MIME part

  - type can be MAILIMAP_SECTION_TEXT_SECTION_MSGTEXT or
    MAILIMAP_SECTION_TEXT_MIME

  - section_msgtext is the part of the MIME part when MIME type is
    message/rfc822 than can be requested, when type is
    MAILIMAP_TEXT_SECTION_MSGTEXT
*/

extern(C)
mailimap_section_text *
mailimap_section_text_new(int sec_type,
    mailimap_section_msgtext * sec_msgtext);
extern(C)
void
mailimap_section_text_free(mailimap_section_text * section_text);









/+
/* ************************************************************************* */
/* the following part concerns only the IMAP command that are sent */


/*
  mailimap_set_item is a message set

  - first is the first message of the set
  - last is the last message of the set

  this can be message numbers of message unique identifiers
*/

struct mailimap_set_item {
  uint set_first;
  uint set_last;
}

LIBETPAN_EXPORT
struct mailimap_set_item *
mailimap_set_item_new(uint set_first, uint set_last);

LIBETPAN_EXPORT
void mailimap_set_item_free(struct mailimap_set_item * set_item);



/*
  set is a list of message sets

  - list is a list of message sets
*/

struct mailimap_set {
  clist * set_list; /* list of (struct mailimap_set_item *) */
}

LIBETPAN_EXPORT
struct mailimap_set * mailimap_set_new(clist * list);

LIBETPAN_EXPORT
void mailimap_set_free(struct mailimap_set * set);


/*
  mailimap_date is a date

  - day is the day in the month (1 to 31)

  - month (1 to 12)

  - year (4 digits)
*/

struct mailimap_date {
  int dt_day;
  int dt_month;
  int dt_year;
}

struct mailimap_date *
mailimap_date_new(int dt_day, int dt_month, int dt_year);

void mailimap_date_free(struct mailimap_date * date);




/* this is the type of fetch attribute for a given message */

enum {
  MAILIMAP_FETCH_ATT_ENVELOPE,          /* to fetch the headers parsed by
                                           the IMAP server */
  MAILIMAP_FETCH_ATT_FLAGS,             /* to fetch the flags */
  MAILIMAP_FETCH_ATT_INTERNALDATE,      /* to fetch the date of the message
                                           kept by the server */
  MAILIMAP_FETCH_ATT_RFC822,            /* to fetch the entire message */
  MAILIMAP_FETCH_ATT_RFC822_HEADER,     /* to fetch the headers */
  MAILIMAP_FETCH_ATT_RFC822_SIZE,       /* to fetch the size */
  MAILIMAP_FETCH_ATT_RFC822_TEXT,       /* to fetch the text part */
  MAILIMAP_FETCH_ATT_BODY,              /* to fetch the MIME structure */
  MAILIMAP_FETCH_ATT_BODYSTRUCTURE,     /* to fetch the MIME structure with
                                           additional information */
  MAILIMAP_FETCH_ATT_UID,               /* to fetch the unique identifier */
  MAILIMAP_FETCH_ATT_BODY_SECTION,      /* to fetch a given part */
  MAILIMAP_FETCH_ATT_BODY_PEEK_SECTION  /* to fetch a given part without
                                           marking the message as read */
}


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
  struct mailimap_section * att_section;
  uint att_offset;
  uint att_size;
}

LIBETPAN_EXPORT
struct mailimap_fetch_att *
mailimap_fetch_att_new(int att_type, struct mailimap_section * att_section,
		       uint att_offset, uint att_size);


LIBETPAN_EXPORT
void mailimap_fetch_att_free(struct mailimap_fetch_att * fetch_att);


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
  union {
    struct mailimap_fetch_att * ft_fetch_att;
    clist * ft_fetch_att_list; /* list of (struct mailimap_fetch_att *) */
  } ft_data;
}

LIBETPAN_EXPORT
struct mailimap_fetch_type *
mailimap_fetch_type_new(int ft_type,
    struct mailimap_fetch_att * ft_fetch_att,
    clist * ft_fetch_att_list);


LIBETPAN_EXPORT
void mailimap_fetch_type_free(struct mailimap_fetch_type * fetch_type);



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
  struct mailimap_flag_list * fl_flag_list;
}

LIBETPAN_EXPORT
struct mailimap_store_att_flags *
mailimap_store_att_flags_new(int fl_sign, int fl_silent,
			     struct mailimap_flag_list * fl_flag_list);

LIBETPAN_EXPORT
void mailimap_store_att_flags_free(struct mailimap_store_att_flags *
    store_att_flags);



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
  union {
    char * sk_bcc;
    struct mailimap_date * sk_before;
    char * sk_body;
    char * sk_cc;
    char * sk_from;
    char * sk_keyword;
    struct mailimap_date * sk_on;
    struct mailimap_date * sk_since;
    char * sk_subject;
    char * sk_text;
    char * sk_to;
    char * sk_unkeyword;
    struct {
      char * sk_header_name;
      char * sk_header_value;
    } sk_header;
    uint sk_larger;
    struct mailimap_search_key * sk_not;
    struct {
      struct mailimap_search_key * sk_or1;
      struct mailimap_search_key * sk_or2;
    } sk_or;
    struct mailimap_date * sk_sentbefore;
    struct mailimap_date * sk_senton;
    struct mailimap_date * sk_sentsince;
    uint sk_smaller;
    struct mailimap_set * sk_uid;
    struct mailimap_set * sk_set;
    clist * sk_multiple; /* list of (struct mailimap_search_key *) */
  } sk_data;
}

LIBETPAN_EXPORT
struct mailimap_search_key *
mailimap_search_key_new(int sk_type,
    char * sk_bcc, struct mailimap_date * sk_before, char * sk_body,
    char * sk_cc, char * sk_from, char * sk_keyword,
    struct mailimap_date * sk_on, struct mailimap_date * sk_since,
    char * sk_subject, char * sk_text, char * sk_to,
    char * sk_unkeyword, char * sk_header_name,
    char * sk_header_value, uint sk_larger,
    struct mailimap_search_key * sk_not,
    struct mailimap_search_key * sk_or1,
    struct mailimap_search_key * sk_or2,
    struct mailimap_date * sk_sentbefore,
    struct mailimap_date * sk_senton,
    struct mailimap_date * sk_sentsince,
    uint sk_smaller, struct mailimap_set * sk_uid,
    struct mailimap_set * sk_set, clist * sk_multiple);


LIBETPAN_EXPORT
void mailimap_search_key_free(struct mailimap_search_key * key);


/*
  mailimap_status_att_list is a list of mailbox STATUS request type

  - list is a list of mailbox STATUS request type
    (value of elements in the list can be MAILIMAP_STATUS_ATT_MESSAGES,
    MAILIMAP_STATUS_ATT_RECENT, MAILIMAP_STATUS_ATT_UIDNEXT,
    MAILIMAP_STATUS_ATT_UIDVALIDITY or MAILIMAP_STATUS_ATT_UNSEEN),
    each element should be allocated with malloc()
*/

struct mailimap_status_att_list {
  clist * att_list; /* list of (uint *) */
}

struct mailimap_status_att_list *
mailimap_status_att_list_new(clist * att_list);

void mailimap_status_att_list_free(struct mailimap_status_att_list *
    status_att_list);




/* internal use functions */


uint * mailimap_number_alloc_new(uint number);

void mailimap_number_alloc_free(uint * pnumber);


void mailimap_addr_host_free(char * addr_host);

void mailimap_addr_mailbox_free(char * addr_mailbox);

void mailimap_addr_adl_free(char * addr_adl);

void mailimap_addr_name_free(char * addr_name);

void mailimap_astring_free(char * astring);

void mailimap_atom_free(char * atom);

void mailimap_auth_type_free(char * auth_type);

void mailimap_base64_free(char * base64);

void mailimap_body_fld_desc_free(char * body_fld_desc);

void mailimap_body_fld_id_free(char * body_fld_id);

void mailimap_body_fld_md5_free(char * body_fld_md5);

void mailimap_body_fld_loc_free(char * body_fld_loc);

void mailimap_env_date_free(char * date);

void mailimap_env_in_reply_to_free(char * in_reply_to);

void mailimap_env_message_id_free(char * message_id);

void mailimap_env_subject_free(char * subject);

void mailimap_flag_extension_free(char * flag_extension);

void mailimap_flag_keyword_free(char * flag_keyword);

void
mailimap_header_fld_name_free(char * header_fld_name);

void mailimap_literal_free(char * literal);

void mailimap_mailbox_free(char * mailbox);

void
mailimap_mailbox_data_search_free(clist * data_search);

void mailimap_media_subtype_free(char * media_subtype);

void mailimap_media_text_free(char * media_text);

void mailimap_msg_att_envelope_free(struct mailimap_envelope * env);

void
mailimap_msg_att_internaldate_free(struct mailimap_date_time * date_time);

void
mailimap_msg_att_rfc822_free(char * str);

void
mailimap_msg_att_rfc822_header_free(char * str);

void
mailimap_msg_att_rfc822_text_free(char * str);

void
mailimap_msg_att_body_free(struct mailimap_body * body);

void
mailimap_msg_att_bodystructure_free(struct mailimap_body * body);

void mailimap_nstring_free(char * str);

void
mailimap_string_free(char * str);

void mailimap_tag_free(char * tag);

void mailimap_text_free(char * text);





/* IMAP connection */

/* this is the state of the IMAP connection */

enum {
  MAILIMAP_STATE_DISCONNECTED,
  MAILIMAP_STATE_NON_AUTHENTICATED,
  MAILIMAP_STATE_AUTHENTICATED,
  MAILIMAP_STATE_SELECTED,
  MAILIMAP_STATE_LOGOUT
}

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

  struct mailimap_connection_info * imap_connection_info;
  struct mailimap_selection_info * imap_selection_info;
  struct mailimap_response_info * imap_response_info;
  
  struct {
    void * sasl_conn;
    const char * sasl_server_fqdn;
    const char * sasl_login;
    const char * sasl_auth_name;
    const char * sasl_password;
    const char * sasl_realm;
    void * sasl_secret;
  } imap_sasl;
  
  time_t imap_idle_timestamp;
  time_t imap_idle_maxdelay;

  mailprogress_function * imap_body_progress_fun;
  mailprogress_function * imap_items_progress_fun;
  void * imap_progress_context;
}

typedef struct mailimap mailimap;


/*
  mailimap_connection_info is the information about the connection
  
  - capability is the list of capability of the IMAP server
*/

struct mailimap_connection_info {
  struct mailimap_capability_data * imap_capability;
}

struct mailimap_connection_info *
mailimap_connection_info_new(void);

void
mailimap_connection_info_free(struct mailimap_connection_info * conn_info);


/* this is the type of mailbox access */

enum {
  MAILIMAP_MAILBOX_READONLY,
  MAILIMAP_MAILBOX_READWRITE
}

/*
  mailimap_selection_info is information about the current selected mailbox

  - perm_flags is a list of flags that can be changed permanently on the
    messages of the mailbox

  - perm is the access on the mailbox, value can be
    MAILIMAP_MAILBOX_READONLY or MAILIMAP_MAILBOX_READWRITE

  - uidnext is the next unique identifier

  - uidvalidity is the unique identifiers validity

  - first_unseen is the number of the first unseen message

  - flags is a list of flags that can be used on the messages of
    the mailbox

  - exists is the number of messages in the mailbox
  
  - recent is the number of recent messages in the mailbox

  - unseen is the number of unseen messages in the mailbox
*/

struct mailimap_selection_info {
  clist * sel_perm_flags; /* list of (struct flag_perm *) */
  int sel_perm;
  uint sel_uidnext;
  uint sel_uidvalidity;
  uint sel_first_unseen;
  struct mailimap_flag_list * sel_flags;
  uint sel_exists;
  uint sel_recent;
  uint sel_unseen;
}

struct mailimap_selection_info *
mailimap_selection_info_new(void);

void
mailimap_selection_info_free(struct mailimap_selection_info * sel_info);


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
  clist * rsp_search_result; /* list of (uint *) */
  struct mailimap_mailbox_data_status * rsp_status;
  clist * rsp_expunged; /* list of (uint 32 *) */
  clist * rsp_fetch_list; /* list of (struct mailimap_msg_att *) */
  clist * rsp_extension_list; /* list of (struct mailimap_extension_data *) */
  char * rsp_atom;
  char * rsp_value;
}

struct mailimap_response_info *
mailimap_response_info_new(void);

void
mailimap_response_info_free(struct mailimap_response_info * resp_info);


/* these are the possible returned error codes */

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


#ifdef __cplusplus
}
#endif

#endif

/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mailimap_types_helper.h,v 1.12 2008/02/20 22:15:52 hoa Exp $
 */

#ifndef MAILIMAP_TYPES_HELPER_H

#define MAILIMAP_TYPES_HELPER_H

#ifdef __cplusplus
extern "C" {
#endif

#include <libetpan/mailimap_types.h>

/*
  IMPORTANT NOTE:
  
  All allocation functions will take as argument allocated data
  and will store these data in the structure they will allocate.
  Data should be persistant during all the use of the structure
  and will be freed by the free function of the structure

  allocation functions will return NULL on failure
*/

/*
  this function creates a new set item with a single message
  given by indx
*/

struct mailimap_set_item * mailimap_set_item_new_single(uint indx);

/*
  this function creates a new set with one set item
 */

struct mailimap_set *
mailimap_set_new_single_item(struct mailimap_set_item * item);

/*
  this function creates a set with a single interval
*/

struct mailimap_set * mailimap_set_new_interval(uint first, uint last);

/*
  this function creates a set with a single message
*/

struct mailimap_set * mailimap_set_new_single(uint indx);

/*
  this function creates an empty set of messages
*/

struct mailimap_set * mailimap_set_new_empty(void);

/*
  this function adds a set item to the set of messages

  @return MAILIMAP_NO_ERROR will be returned on success,
  other code will be returned otherwise
*/

int mailimap_set_add(struct mailimap_set * set,
		struct mailimap_set_item * set_item);

/*
  this function adds an interval to the set

  @return MAILIMAP_NO_ERROR will be returned on success,
  other code will be returned otherwise
*/

int mailimap_set_add_interval(struct mailimap_set * set,
		uint first, uint last);

/*
  this function adds a single message to the set

  @return MAILIMAP_NO_ERROR will be returned on success,
  other code will be returned otherwise
*/

int mailimap_set_add_single(struct mailimap_set * set,
			 uint indx);

/*
  this function creates a mailimap_section structure to request
  the header of a message
*/

struct mailimap_section * mailimap_section_new_header(void);

/*
  this functions creates a mailimap_section structure to describe
  a list of headers
*/

struct mailimap_section *
mailimap_section_new_header_fields(struct mailimap_header_list * header_list);

/*
  this functions creates a mailimap_section structure to describe headers
  other than those given
*/

struct mailimap_section *
mailimap_section_new_header_fields_not(struct mailimap_header_list * header_list);

/*
  this function creates a mailimap_section structure to describe the
  text of a message
 */

struct mailimap_section * mailimap_section_new_text(void);

/*
  this function creates a mailimap_section structure to describe the 
  content of a MIME part
*/

struct mailimap_section *
mailimap_section_new_part(struct mailimap_section_part * part);

/*
  this function creates a mailimap_section structure to describe the
  MIME fields of a MIME part
*/

struct mailimap_section *
mailimap_section_new_part_mime(struct mailimap_section_part * part);

/*
  this function creates a mailimap_section structure to describe the
  headers of a MIME part if the MIME type is a message/rfc822
*/

struct mailimap_section *
mailimap_section_new_part_header(struct mailimap_section_part * part);

/*
  this function creates a mailimap_section structure to describe
  a list of headers of a MIME part if the MIME type is a message/rfc822
*/

struct mailimap_section *
mailimap_section_new_part_header_fields(struct mailimap_section_part *
					part,
					struct mailimap_header_list *
					header_list);

/*
  this function creates a mailimap_section structure to describe
  headers of a MIME part other than those given if the MIME type
  is a message/rfc822
*/

struct mailimap_section *
mailimap_section_new_part_header_fields_not(struct mailimap_section_part
					    * part,
					    struct mailimap_header_list
					    * header_list);

/*
  this function creates a mailimap_section structure to describe
  text part of message if the MIME type is a message/rfc822
*/

struct mailimap_section *
mailimap_section_new_part_text(struct mailimap_section_part * part);


/*
  this function creates a mailimap_fetch_att structure to request
  envelope of a message
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_envelope(void);


/*
  this function creates a mailimap_fetch_att structure to request
  flags of a message
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_flags(void);

/*
  this function creates a mailimap_fetch_att structure to request
  internal date of a message
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_internaldate(void);


/*
  this function creates a mailimap_fetch_att structure to request
  text part of a message
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_rfc822(void);


/*
  this function creates a mailimap_fetch_att structure to request
  header of a message
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_rfc822_header(void);

/*
  this function creates a mailimap_fetch_att structure to request
  size of a message
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_rfc822_size(void);

/*
  this function creates a mailimap_fetch_att structure to request
  envelope of a message
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_rfc822_text(void);

/*
  this function creates a mailimap_fetch_att structure to request
  the MIME structure of a message
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_body(void);

/*
  this function creates a mailimap_fetch_att structure to request
  the MIME structure of a message and additional MIME information
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_bodystructure(void);

/*
  this function creates a mailimap_fetch_att structure to request
  unique identifier of a message
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_uid(void);

/*
  this function creates a mailimap_fetch_att structure to request
  a given section of a message
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_body_section(struct mailimap_section * section);

/*
  this function creates a mailimap_fetch_att structure to request
  a given section of a message without marking it as read
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_body_peek_section(struct mailimap_section * section);

/*
  this function creates a mailimap_fetch_att structure to request
  a part of a section of a message
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_body_section_partial(struct mailimap_section * section,
					    uint offset, uint size);

/*
  this function creates a mailimap_fetch_att structure to request
  a part of a section of a message without marking it as read
*/

struct mailimap_fetch_att *
mailimap_fetch_att_new_body_peek_section_partial(struct mailimap_section * section,
						 uint offset, uint size);

/*
  this function creates a mailimap_fetch_type structure to request
  (FLAGS INTERNALDATE RFC822.SIZE ENVELOPE) of a message
*/

struct mailimap_fetch_type *
mailimap_fetch_type_new_all(void);

/*
  this function creates a mailimap_fetch_type structure to request
  (FLAGS INTERNALDATE RFC822.SIZE ENVELOPE BODY)
*/

struct mailimap_fetch_type *
mailimap_fetch_type_new_full(void);

/*
  this function creates a mailimap_fetch_type structure to request
  (FLAGS INTERNALDATE RFC822.SIZE)
*/

struct mailimap_fetch_type *
mailimap_fetch_type_new_fast(void);

/*
  this function creates a mailimap_fetch_type structure to request
  the given fetch attribute
*/

struct mailimap_fetch_type *
mailimap_fetch_type_new_fetch_att(struct mailimap_fetch_att * fetch_att);

/*
  this function creates a mailimap_fetch_type structure to request
  the list of fetch attributes
*/

struct mailimap_fetch_type *
mailimap_fetch_type_new_fetch_att_list(clist * fetch_att_list);

/*
  this function creates a mailimap_fetch_type structure
*/

struct mailimap_fetch_type *
mailimap_fetch_type_new_fetch_att_list_empty(void);

/*
  this function adds a given fetch attribute to the mailimap_fetch
  structure

  @return MAILIMAP_NO_ERROR will be returned on success,
  other code will be returned otherwise
*/

int
mailimap_fetch_type_new_fetch_att_list_add(struct mailimap_fetch_type *
					   fetch_type,
					   struct mailimap_fetch_att *
					   fetch_att);

/*
  this function creates a store attribute to set the given flags
*/

struct mailimap_store_att_flags *
mailimap_store_att_flags_new_set_flags(struct mailimap_flag_list * flags);

/*
  this function creates a store attribute to silently set the given flags
*/

struct mailimap_store_att_flags *
mailimap_store_att_flags_new_set_flags_silent(struct mailimap_flag_list *
					      flags);

/*
  this function creates a store attribute to add the given flags
*/

struct mailimap_store_att_flags *
mailimap_store_att_flags_new_add_flags(struct mailimap_flag_list * flags);

/*
  this function creates a store attribute to add silently the given flags
*/

struct mailimap_store_att_flags *
mailimap_store_att_flags_new_add_flags_silent(struct mailimap_flag_list *
					      flags);

/*
  this function creates a store attribute to remove the given flags
*/

struct mailimap_store_att_flags *
mailimap_store_att_flags_new_remove_flags(struct mailimap_flag_list * flags);

/*
  this function creates a store attribute to remove silently the given flags
*/

struct mailimap_store_att_flags *
mailimap_store_att_flags_new_remove_flags_silent(struct mailimap_flag_list *
						 flags);


/*
  this function creates a condition structure to match all messages
*/

struct mailimap_search_key *
mailimap_search_key_new_all(void);

/*
  this function creates a condition structure to match messages with Bcc field
  
  @param bcc this is the content of Bcc to match, it should be allocated
    with malloc()
*/

struct mailimap_search_key *
mailimap_search_key_new_bcc(char * sk_bcc);

/*
  this function creates a condition structure to match messages with
  internal date
*/

struct mailimap_search_key *
mailimap_search_key_new_before(struct mailimap_date * sk_before);

/*
  this function creates a condition structure to match messages with
  message content

  @param body this is the content of the message to match, it should
    be allocated with malloc()
*/

struct mailimap_search_key *
mailimap_search_key_new_body(char * sk_body);

/*
  this function creates a condition structure to match messages with 
  Cc field

  
  @param cc this is the content of Cc to match, it should be allocated
    with malloc()
*/

struct mailimap_search_key *
mailimap_search_key_new_cc(char * sk_cc);

/*
  this function creates a condition structure to match messages with 
  From field

  @param from this is the content of From to match, it should be allocated
    with malloc()
*/

struct mailimap_search_key *
mailimap_search_key_new_from(char * sk_from);

/*
  this function creates a condition structure to match messages with 
  a flag given by keyword
*/

struct mailimap_search_key *
mailimap_search_key_new_keyword(char * sk_keyword);

/*
  this function creates a condition structure to match messages with
  internal date
*/

struct mailimap_search_key *
mailimap_search_key_new_on(struct mailimap_date * sk_on);

/*
  this function creates a condition structure to match messages with
  internal date
*/

struct mailimap_search_key *
mailimap_search_key_new_since(struct mailimap_date * sk_since);

/*
  this function creates a condition structure to match messages with 
  Subject field

  @param subject this is the content of Subject to match, it should
    be allocated with malloc()
*/

struct mailimap_search_key *
mailimap_search_key_new_subject(char * sk_subject);

/*
  this function creates a condition structure to match messages with
  message text part

  @param text this is the message text to match, it should
    be allocated with malloc()
*/

struct mailimap_search_key *
mailimap_search_key_new_text(char * sk_text);

/*
  this function creates a condition structure to match messages with 
  To field

  @param to this is the content of To to match, it should be allocated
    with malloc()
*/

struct mailimap_search_key *
mailimap_search_key_new_to(char * sk_to);

/*
  this function creates a condition structure to match messages with 
  no a flag given by unkeyword
*/

struct mailimap_search_key *
mailimap_search_key_new_unkeyword(char * sk_unkeyword);

/*
  this function creates a condition structure to match messages with 
  the given field

  @param header_name this is the name of the field to match, it
    should be allocated with malloc()

  @param header_value this is the content, it should be allocated
    with malloc()
*/

struct mailimap_search_key *
mailimap_search_key_new_header(char * sk_header_name, char * sk_header_value);


/*
  this function creates a condition structure to match messages with size
*/

struct mailimap_search_key *
mailimap_search_key_new_larger(uint sk_larger);

/*
  this function creates a condition structure to match messages that
  do not match the given condition
*/

struct mailimap_search_key *
mailimap_search_key_new_not(struct mailimap_search_key * sk_not);

/*
  this function creates a condition structure to match messages that
  match one of the given conditions
*/

struct mailimap_search_key *
mailimap_search_key_new_or(struct mailimap_search_key * sk_or1,
			   struct mailimap_search_key * sk_or2);

/*
  this function creates a condition structure to match messages
  with Date field
*/

struct mailimap_search_key *
mailimap_search_key_new_sentbefore(struct mailimap_date * sk_sentbefore);

/*
  this function creates a condition structure to match messages
  with Date field
*/

struct mailimap_search_key *
mailimap_search_key_new_senton(struct mailimap_date * sk_senton);

/*
  this function creates a condition structure to match messages
  with Date field
*/

struct mailimap_search_key *
mailimap_search_key_new_sentsince(struct mailimap_date * sk_sentsince);

/*
  this function creates a condition structure to match messages with size
*/

struct mailimap_search_key *
mailimap_search_key_new_smaller(uint sk_smaller);

/*
  this function creates a condition structure to match messages with unique
  identifier
*/

struct mailimap_search_key *
mailimap_search_key_new_uid(struct mailimap_set * sk_uid);

/*
  this function creates a condition structure to match messages with number
  or unique identifier (depending whether SEARCH or UID SEARCH is used)
*/

struct mailimap_search_key *
mailimap_search_key_new_set(struct mailimap_set * sk_set);

/*
  this function creates a condition structure to match messages that match
  all the conditions given in the list
*/

struct mailimap_search_key *
mailimap_search_key_new_multiple(clist * sk_multiple);


/*
  same as previous but the list is empty
*/

struct mailimap_search_key *
mailimap_search_key_new_multiple_empty(void);

/*
  this function adds a condition to the condition list

  @return MAILIMAP_NO_ERROR will be returned on success,
  other code will be returned otherwise
*/

int
mailimap_search_key_multiple_add(struct mailimap_search_key * keys,
				 struct mailimap_search_key * key_item);


/*
  this function creates an empty list of flags
*/

struct mailimap_flag_list *
mailimap_flag_list_new_empty(void);

/*
  this function adds a flag to the list of flags

  @return MAILIMAP_NO_ERROR will be returned on success,
  other code will be returned otherwise
*/

int mailimap_flag_list_add(struct mailimap_flag_list * flag_list,
				struct mailimap_flag * f);

/*
  this function creates a \Answered flag
*/

struct mailimap_flag * mailimap_flag_new_answered(void);

/*
  this function creates a \Flagged flag
*/

struct mailimap_flag * mailimap_flag_new_flagged(void);

/*
  this function creates a \Deleted flag
*/

struct mailimap_flag * mailimap_flag_new_deleted(void);

/*
  this function creates a \Seen flag
*/

struct mailimap_flag * mailimap_flag_new_seen(void);

/*
  this function creates a \Draft flag
*/

struct mailimap_flag * mailimap_flag_new_draft(void);

/*
  this function creates a keyword flag

  @param flag_keyword this should be allocated with malloc()
*/

struct mailimap_flag * mailimap_flag_new_flag_keyword(char * flag_keyword);


/*
  this function creates an extension flag

  @param flag_extension this should be allocated with malloc()
*/

struct mailimap_flag * mailimap_flag_new_flag_extension(char * flag_extension);

/*
  this function creates an empty list of status attributes
*/

struct mailimap_status_att_list * mailimap_status_att_list_new_empty(void);

/*
  this function adds status attributes to the list

  @return MAILIMAP_NO_ERROR will be returned on success,
  other code will be returned otherwise
*/

int
mailimap_status_att_list_add(struct mailimap_status_att_list * sa_list,
			     int status_att);

/* return mailimap_section_part from a given mailimap_body */

int mailimap_get_section_part_from_body(struct mailimap_body * root_part,
    struct mailimap_body * part,
    struct mailimap_section_part ** result);

#ifdef __cplusplus
}
#endif

#endif
/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mailimap_ssl.h,v 1.16 2006/12/26 13:13:24 hoa Exp $
 */

#ifndef MAILIMAP_SSL_H

#define MAILIMAP_SSL_H

#ifdef __cplusplus
extern "C" {
#endif

#ifdef HAVE_INTTYPES_H
#	include <inttypes.h>
#endif

#include <libetpan/mailimap_types.h>

LIBETPAN_EXPORT
int mailimap_ssl_connect(mailimap * f, const char * server, uint16_t port);

LIBETPAN_EXPORT
int mailimap_ssl_connect_with_callback(mailimap * f, const char * server, uint16_t port,
    void (* callback)(struct mailstream_ssl_context * ssl_context, void * data), void * data);

#ifdef __cplusplus
}
#endif

#endif
/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

/*
 * $Id: mailimf.h,v 1.28 2008/05/27 10:07:55 hoa Exp $
 */

#ifndef MAILIMF_H

#define MAILIMF_H

#ifdef __cplusplus
extern "C" {
#endif

#include <libetpan/mailimf_types.h>
#include <libetpan/mailimf_write_generic.h>
#include <libetpan/mailimf_write_file.h>
#include <libetpan/mailimf_write_mem.h>
#include <libetpan/mailimf_types_helper.h>

#ifdef HAVE_INTTYPES_H
#	include <inttypes.h>
#endif
#ifdef HAVE_SYS_TYPES_H
#	include <sys/types.h>
#endif

/*
  mailimf_message_parse will parse the given message
  
  @param message this is a string containing the message content
  @param length this is the size of the given string
  @param indx this is a pointer to the start of the message in
    the given string, (* indx) is modified to point at the end
    of the parsed data
  @param result the result of the parse operation is stored in
    (* result)

  @return MAILIMF_NO_ERROR on success, MAILIMF_ERROR_XXX on error
*/
LIBETPAN_EXPORT
int mailimf_message_parse(const char * message, size_t length,
			  size_t * indx,
			  struct mailimf_message ** result);

/*
  mailimf_body_parse will parse the given text part of a message
  
  @param message this is a string containing the message text part
  @param length this is the size of the given string
  @param indx this is a pointer to the start of the message text part in
    the given string, (* indx) is modified to point at the end
    of the parsed data
  @param result the result of the parse operation is stored in
    (* result)

  @return MAILIMF_NO_ERROR on success, MAILIMF_ERROR_XXX on error
*/
LIBETPAN_EXPORT
int mailimf_body_parse(const char * message, size_t length,
		       size_t * indx,
		       struct mailimf_body ** result);

/*
  mailimf_fields_parse will parse the given header fields
  
  @param message this is a string containing the header fields
  @param length this is the size of the given string
  @param indx this is a pointer to the start of the header fields in
    the given string, (* indx) is modified to point at the end
    of the parsed data
  @param result the result of the parse operation is stored in
    (* result)

  @return MAILIMF_NO_ERROR on success, MAILIMF_ERROR_XXX on error
*/
LIBETPAN_EXPORT
int mailimf_fields_parse(const char * message, size_t length,
			 size_t * indx,
			 struct mailimf_fields ** result);

/*
  mailimf_mailbox_list_parse will parse the given mailbox list
  
  @param message this is a string containing the mailbox list
  @param length this is the size of the given string
  @param indx this is a pointer to the start of the mailbox list in
    the given string, (* indx) is modified to point at the end
    of the parsed data
  @param result the result of the parse operation is stored in
    (* result)

  @return MAILIMF_NO_ERROR on success, MAILIMF_ERROR_XXX on error
*/
LIBETPAN_EXPORT
int
mailimf_mailbox_list_parse(const char * message, size_t length,
			   size_t * indx,
			   struct mailimf_mailbox_list ** result);

/*
  mailimf_address_list_parse will parse the given address list
  
  @param message this is a string containing the address list
  @param length this is the size of the given string
  @param indx this is a pointer to the start of the address list in
    the given string, (* indx) is modified to point at the end
    of the parsed data
  @param result the result of the parse operation is stored in
    (* result)

  @return MAILIMF_NO_ERROR on success, MAILIMF_ERROR_XXX on error
*/
LIBETPAN_EXPORT
int
mailimf_address_list_parse(const char * message, size_t length,
			   size_t * indx,
			   struct mailimf_address_list ** result);

/*
  mailimf_address_parse will parse the given address
  
  @param message this is a string containing the address
  @param length this is the size of the given string
  @param indx this is a pointer to the start of the address in
    the given string, (* indx) is modified to point at the end
    of the parsed data
  @param result the result of the parse operation is stored in
    (* result)

  @return MAILIMF_NO_ERROR on success, MAILIMF_ERROR_XXX on error
*/
LIBETPAN_EXPORT
int mailimf_address_parse(const char * message, size_t length,
			  size_t * indx,
			  struct mailimf_address ** result);

/*
  mailimf_mailbox_parse will parse the given address
  
  @param message this is a string containing the mailbox
  @param length this is the size of the given string
  @param indx this is a pointer to the start of the mailbox in
    the given string, (* indx) is modified to point at the end
    of the parsed data
  @param result the result of the parse operation is stored in
    (* result)

  @return MAILIMF_NO_ERROR on success, MAILIMF_ERROR_XXX on error
*/
LIBETPAN_EXPORT
int mailimf_mailbox_parse(const char * message, size_t length,
			  size_t * indx,
			  struct mailimf_mailbox ** result);

/*
  mailimf_date_time_parse will parse the given RFC 2822 date
  
  @param message this is a string containing the date
  @param length this is the size of the given string
  @param indx this is a pointer to the start of the date in
    the given string, (* indx) is modified to point at the end
    of the parsed data
  @param result the result of the parse operation is stored in
    (* result)

  @return MAILIMF_NO_ERROR on success, MAILIMF_ERROR_XXX on error
*/
LIBETPAN_EXPORT
int mailimf_date_time_parse(const char * message, size_t length,
			    size_t * indx,
			    struct mailimf_date_time ** result);

/*
  mailimf_envelope_fields_parse will parse the given fields (Date,
  From, Sender, Reply-To, To, Cc, Bcc, Message-ID, In-Reply-To,
  References and Subject)
  
  @param message this is a string containing the header fields
  @param length this is the size of the given string
  @param indx this is a pointer to the start of the header fields in
    the given string, (* indx) is modified to point at the end
    of the parsed data
  @param result the result of the parse operation is stored in
    (* result)

  @return MAILIMF_NO_ERROR on success, MAILIMF_ERROR_XXX on error
*/
LIBETPAN_EXPORT
int mailimf_envelope_fields_parse(const char * message, size_t length,
				  size_t * indx,
				  struct mailimf_fields ** result);

/*
  mailimf_ignore_field_parse will skip the given field
  
  @param message this is a string containing the header field
  @param length this is the size of the given string
  @param indx this is a pointer to the start of the header field in
    the given string, (* indx) is modified to point at the end
    of the parsed data

  @return MAILIMF_NO_ERROR on success, MAILIMF_ERROR_XXX on error
*/

LIBETPAN_EXPORT
int mailimf_ignore_field_parse(const char * message, size_t length,
			       size_t * indx);

/*
  mailimf_envelope_fields will parse the given fields (Date,
  From, Sender, Reply-To, To, Cc, Bcc, Message-ID, In-Reply-To,
  References and Subject), other fields will be added as optional
  fields.
  
  @param message this is a string containing the header fields
  @param length this is the size of the given string
  @param indx this is a pointer to the start of the header fields in
    the given string, (* indx) is modified to point at the end
    of the parsed data
  @param result the result of the parse operation is stored in
    (* result)

  @return MAILIMF_NO_ERROR on success, MAILIMF_ERROR_XXX on error
*/

LIBETPAN_EXPORT
int
mailimf_envelope_and_optional_fields_parse(const char * message, size_t length,
					   size_t * indx,
					   struct mailimf_fields ** result);

/*
  mailimf_envelope_fields will parse the given fields as optional
  fields.
  
  @param message this is a string containing the header fields
  @param length this is the size of the given string
  @param indx this is a pointer to the start of the header fields in
    the given string, (* indx) is modified to point at the end
    of the parsed data
  @param result the result of the parse operation is stored in
    (* result)

  @return MAILIMF_NO_ERROR on success, MAILIMF_ERROR_XXX on error
*/
LIBETPAN_EXPORT
int
mailimf_optional_fields_parse(const char * message, size_t length,
			      size_t * indx,
			      struct mailimf_fields ** result);


/* internal use, exported for MIME */

int mailimf_fws_parse(const char * message, size_t length, size_t * indx);

int mailimf_cfws_parse(const char * message, size_t length,
		       size_t * indx);

int mailimf_char_parse(const char * message, size_t length,
		       size_t * indx, char token);

int mailimf_unstrict_char_parse(const char * message, size_t length,
				size_t * indx, char token);

int mailimf_crlf_parse(const char * message, size_t length, size_t * indx);

int
mailimf_custom_string_parse(const char * message, size_t length,
			    size_t * indx, char ** result,
			    int (* is_custom_char)(char));

int
mailimf_token_case_insensitive_len_parse(const char * message, size_t length,
					 size_t * indx, char * token,
					 size_t token_length);

#define mailimf_token_case_insensitive_parse(message, length, indx, token) \
    mailimf_token_case_insensitive_len_parse(message, length, indx, token, \
					     strlen(token))

int mailimf_quoted_string_parse(const char * message, size_t length,
				size_t * indx, char ** result);

int
mailimf_number_parse(const char * message, size_t length,
		     size_t * indx, uint * result);

int mailimf_msg_id_parse(const char * message, size_t length,
			 size_t * indx,
			 char ** result);

int mailimf_msg_id_list_parse(const char * message, size_t length,
			      size_t * indx, clist ** result);

int mailimf_word_parse(const char * message, size_t length,
		       size_t * indx, char ** result);

int mailimf_atom_parse(const char * message, size_t length,
		       size_t * indx, char ** result);

int mailimf_fws_atom_parse(const char * message, size_t length,
			   size_t * indx, char ** result);

int mailimf_fws_word_parse(const char * message, size_t length,
			   size_t * indx, char ** result);

int mailimf_fws_quoted_string_parse(const char * message, size_t length,
				    size_t * indx, char ** result);

/* exported for IMAP */

int mailimf_references_parse(const char * message, size_t length,
			     size_t * indx,
			     struct mailimf_references ** result);

#ifdef __cplusplus
}
#endif

#endif
/*
 * libEtPan! -- a mail stuff library
 *
 * Copyright (C) 2001, 2005 - DINH Viet Hoa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the libEtPan! project nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */


/*
 * $Id: mailimf_types.h,v 1.34 2006/05/22 13:39:42 hoa Exp $
 */

#ifndef MAILIMF_TYPES_H

#define MAILIMF_TYPES_H

#ifdef __cplusplus
extern "C" {
#endif

#include <libetpan/libetpan-config.h>
#include <libetpan/clist.h>
#include <sys/types.h>

/*
  IMPORTANT NOTE:
  
  All allocation functions will take as argument allocated data
  and will store these data in the structure they will allocate.
  Data should be persistant during all the use of the structure
  and will be freed by the free function of the structure

  allocation functions will return NULL on failure
*/

/*
  mailimf_date_time is a date
  
  - day is the day of month (1 to 31)

  - month (1 to 12)

  - year (4 digits)

  - hour (0 to 23)

  - min (0 to 59)

  - sec (0 to 59)

  - zone (this is the decimal value that we can read, for example:
    for "-0200", the value is -200)
*/

struct mailimf_date_time {
  int dt_day;
  int dt_month;
  int dt_year;
  int dt_hour;
  int dt_min;
  int dt_sec;
  int dt_zone;
}

LIBETPAN_EXPORT
struct mailimf_date_time *
mailimf_date_time_new(int dt_day, int dt_month, int dt_year,
    int dt_hour, int dt_min, int dt_sec, int dt_zone);

LIBETPAN_EXPORT
void mailimf_date_time_free(struct mailimf_date_time * date_time);



/* this is the type of address */

enum {
  MAILIMF_ADDRESS_ERROR,   /* on parse error */
  MAILIMF_ADDRESS_MAILBOX, /* if this is a mailbox (mailbox@domain) */
  MAILIMF_ADDRESS_GROUP    /* if this is a group
                              (group_name: address1@domain1,
                                  address2@domain2; ) */
}

/*
  mailimf_address is an address

  - type can be MAILIMF_ADDRESS_MAILBOX or MAILIMF_ADDRESS_GROUP

  - mailbox is a mailbox if type is MAILIMF_ADDRESS_MAILBOX

  - group is a group if type is MAILIMF_ADDRESS_GROUP
*/

struct mailimf_address {
  int ad_type;
  union {
    struct mailimf_mailbox * ad_mailbox; /* can be NULL */
    struct mailimf_group * ad_group;     /* can be NULL */
  } ad_data;
}

LIBETPAN_EXPORT
struct mailimf_address *
mailimf_address_new(int ad_type, struct mailimf_mailbox * ad_mailbox,
    struct mailimf_group * ad_group);

LIBETPAN_EXPORT
void mailimf_address_free(struct mailimf_address * address);



/*
  mailimf_mailbox is a mailbox

  - display_name is the name that will be displayed for this mailbox,
    for example 'name' in '"name" <mailbox@domain>,
    should be allocated with malloc()
  
  - addr_spec is the mailbox, for example 'mailbox@domain'
    in '"name" <mailbox@domain>, should be allocated with malloc()
*/

struct mailimf_mailbox {
  char * mb_display_name; /* can be NULL */
  char * mb_addr_spec;    /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_mailbox *
mailimf_mailbox_new(char * mb_display_name, char * mb_addr_spec);

LIBETPAN_EXPORT
void mailimf_mailbox_free(struct mailimf_mailbox * mailbox);



/*
  mailimf_group is a group

  - display_name is the name that will be displayed for this group,
    for example 'group_name' in
    'group_name: address1@domain1, address2@domain2;', should be allocated
    with malloc()

  - mb_list is a list of mailboxes
*/

struct mailimf_group {
  char * grp_display_name; /* != NULL */
  struct mailimf_mailbox_list * grp_mb_list; /* can be NULL */
}

LIBETPAN_EXPORT
struct mailimf_group *
mailimf_group_new(char * grp_display_name,
    struct mailimf_mailbox_list * grp_mb_list);

LIBETPAN_EXPORT
void mailimf_group_free(struct mailimf_group * group);



/*
  mailimf_mailbox_list is a list of mailboxes

  - list is a list of mailboxes
*/

struct mailimf_mailbox_list {
  clist * mb_list; /* list of (struct mailimf_mailbox *), != NULL */
}

LIBETPAN_EXPORT
struct mailimf_mailbox_list *
mailimf_mailbox_list_new(clist * mb_list);

LIBETPAN_EXPORT
void mailimf_mailbox_list_free(struct mailimf_mailbox_list * mb_list);



/*
  mailimf_address_list is a list of addresses

  - list is a list of addresses
*/

struct mailimf_address_list {
  clist * ad_list; /* list of (struct mailimf_address *), != NULL */
}

LIBETPAN_EXPORT
struct mailimf_address_list *
mailimf_address_list_new(clist * ad_list);

LIBETPAN_EXPORT
void mailimf_address_list_free(struct mailimf_address_list * addr_list);





/*
  mailimf_body is the text part of a message
  
  - text is the beginning of the text part, it is a substring
    of an other string

  - size is the size of the text part
*/

struct mailimf_body {
  const char * bd_text; /* != NULL */
  size_t bd_size;
}

LIBETPAN_EXPORT
struct mailimf_body * mailimf_body_new(const char * bd_text, size_t bd_size);

LIBETPAN_EXPORT
void mailimf_body_free(struct mailimf_body * body);




/*
  mailimf_message is the content of the message

  - msg_fields is the header fields of the message
  
  - msg_body is the text part of the message
*/

struct mailimf_message {
  struct mailimf_fields * msg_fields; /* != NULL */
  struct mailimf_body * msg_body;     /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_message *
mailimf_message_new(struct mailimf_fields * msg_fields,
    struct mailimf_body * msg_body);

LIBETPAN_EXPORT
void mailimf_message_free(struct mailimf_message * message);




/*
  mailimf_fields is a list of header fields

  - fld_list is a list of header fields
*/

struct mailimf_fields {
  clist * fld_list; /* list of (struct mailimf_field *), != NULL */
}

LIBETPAN_EXPORT
struct mailimf_fields * mailimf_fields_new(clist * fld_list);

LIBETPAN_EXPORT
void mailimf_fields_free(struct mailimf_fields * fields);



/* this is a type of field */

enum {
  MAILIMF_FIELD_NONE,           /* on parse error */
  MAILIMF_FIELD_RETURN_PATH,    /* Return-Path */
  MAILIMF_FIELD_RESENT_DATE,    /* Resent-Date */
  MAILIMF_FIELD_RESENT_FROM,    /* Resent-From */
  MAILIMF_FIELD_RESENT_SENDER,  /* Resent-Sender */
  MAILIMF_FIELD_RESENT_TO,      /* Resent-To */
  MAILIMF_FIELD_RESENT_CC,      /* Resent-Cc */
  MAILIMF_FIELD_RESENT_BCC,     /* Resent-Bcc */
  MAILIMF_FIELD_RESENT_MSG_ID,  /* Resent-Message-ID */
  MAILIMF_FIELD_ORIG_DATE,      /* Date */
  MAILIMF_FIELD_FROM,           /* From */
  MAILIMF_FIELD_SENDER,         /* Sender */
  MAILIMF_FIELD_REPLY_TO,       /* Reply-To */
  MAILIMF_FIELD_TO,             /* To */
  MAILIMF_FIELD_CC,             /* Cc */
  MAILIMF_FIELD_BCC,            /* Bcc */
  MAILIMF_FIELD_MESSAGE_ID,     /* Message-ID */
  MAILIMF_FIELD_IN_REPLY_TO,    /* In-Reply-To */
  MAILIMF_FIELD_REFERENCES,     /* References */
  MAILIMF_FIELD_SUBJECT,        /* Subject */
  MAILIMF_FIELD_COMMENTS,       /* Comments */
  MAILIMF_FIELD_KEYWORDS,       /* Keywords */
  MAILIMF_FIELD_OPTIONAL_FIELD  /* other field */
}

/*
  mailimf_field is a field

  - fld_type is the type of the field

  - fld_data.fld_return_path is the parsed content of the Return-Path
    field if type is MAILIMF_FIELD_RETURN_PATH

  - fld_data.fld_resent_date is the parsed content of the Resent-Date field
    if type is MAILIMF_FIELD_RESENT_DATE

  - fld_data.fld_resent_from is the parsed content of the Resent-From field

  - fld_data.fld_resent_sender is the parsed content of the Resent-Sender field

  - fld_data.fld_resent_to is the parsed content of the Resent-To field

  - fld_data.fld_resent_cc is the parsed content of the Resent-Cc field

  - fld_data.fld_resent_bcc is the parsed content of the Resent-Bcc field

  - fld_data.fld_resent_msg_id is the parsed content of the Resent-Message-ID
    field

  - fld_data.fld_orig_date is the parsed content of the Date field

  - fld_data.fld_from is the parsed content of the From field

  - fld_data.fld_sender is the parsed content of the Sender field

  - fld_data.fld_reply_to is the parsed content of the Reply-To field

  - fld_data.fld_to is the parsed content of the To field

  - fld_data.fld_cc is the parsed content of the Cc field

  - fld_data.fld_bcc is the parsed content of the Bcc field

  - fld_data.fld_message_id is the parsed content of the Message-ID field

  - fld_data.fld_in_reply_to is the parsed content of the In-Reply-To field

  - fld_data.fld_references is the parsed content of the References field

  - fld_data.fld_subject is the content of the Subject field

  - fld_data.fld_comments is the content of the Comments field

  - fld_data.fld_keywords is the parsed content of the Keywords field

  - fld_data.fld_optional_field is an other field and is not parsed
*/

#define LIBETPAN_MAILIMF_FIELD_UNION

struct mailimf_field {
  int fld_type;
  union {
    struct mailimf_return * fld_return_path;              /* can be NULL */
    struct mailimf_orig_date * fld_resent_date;    /* can be NULL */
    struct mailimf_from * fld_resent_from;         /* can be NULL */
    struct mailimf_sender * fld_resent_sender;     /* can be NULL */
    struct mailimf_to * fld_resent_to;             /* can be NULL */
    struct mailimf_cc * fld_resent_cc;             /* can be NULL */
    struct mailimf_bcc * fld_resent_bcc;           /* can be NULL */
    struct mailimf_message_id * fld_resent_msg_id; /* can be NULL */
    struct mailimf_orig_date * fld_orig_date;             /* can be NULL */
    struct mailimf_from * fld_from;                       /* can be NULL */
    struct mailimf_sender * fld_sender;                   /* can be NULL */
    struct mailimf_reply_to * fld_reply_to;               /* can be NULL */
    struct mailimf_to * fld_to;                           /* can be NULL */
    struct mailimf_cc * fld_cc;                           /* can be NULL */
    struct mailimf_bcc * fld_bcc;                         /* can be NULL */
    struct mailimf_message_id * fld_message_id;           /* can be NULL */
    struct mailimf_in_reply_to * fld_in_reply_to;         /* can be NULL */
    struct mailimf_references * fld_references;           /* can be NULL */
    struct mailimf_subject * fld_subject;                 /* can be NULL */
    struct mailimf_comments * fld_comments;               /* can be NULL */
    struct mailimf_keywords * fld_keywords;               /* can be NULL */
    struct mailimf_optional_field * fld_optional_field;   /* can be NULL */
  } fld_data;
}

LIBETPAN_EXPORT
struct mailimf_field *
mailimf_field_new(int fld_type,
    struct mailimf_return * fld_return_path,
    struct mailimf_orig_date * fld_resent_date,
    struct mailimf_from * fld_resent_from,
    struct mailimf_sender * fld_resent_sender,
    struct mailimf_to * fld_resent_to,
    struct mailimf_cc * fld_resent_cc,
    struct mailimf_bcc * fld_resent_bcc,
    struct mailimf_message_id * fld_resent_msg_id,
    struct mailimf_orig_date * fld_orig_date,
    struct mailimf_from * fld_from,
    struct mailimf_sender * fld_sender,
    struct mailimf_reply_to * fld_reply_to,
    struct mailimf_to * fld_to,
    struct mailimf_cc * fld_cc,
    struct mailimf_bcc * fld_bcc,
    struct mailimf_message_id * fld_message_id,
    struct mailimf_in_reply_to * fld_in_reply_to,
    struct mailimf_references * fld_references,
    struct mailimf_subject * fld_subject,
    struct mailimf_comments * fld_comments,
    struct mailimf_keywords * fld_keywords,
    struct mailimf_optional_field * fld_optional_field);

LIBETPAN_EXPORT
void mailimf_field_free(struct mailimf_field * field);



/*
  mailimf_orig_date is the parsed Date field

  - date_time is the parsed date
*/

struct mailimf_orig_date {
  struct mailimf_date_time * dt_date_time; /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_orig_date * mailimf_orig_date_new(struct mailimf_date_time *
    dt_date_time);

LIBETPAN_EXPORT
void mailimf_orig_date_free(struct mailimf_orig_date * orig_date);




/*
  mailimf_from is the parsed From field

  - mb_list is the parsed mailbox list
*/

struct mailimf_from {
  struct mailimf_mailbox_list * frm_mb_list; /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_from *
mailimf_from_new(struct mailimf_mailbox_list * frm_mb_list);

LIBETPAN_EXPORT
void mailimf_from_free(struct mailimf_from * from);



/*
  mailimf_sender is the parsed Sender field

  - snd_mb is the parsed mailbox
*/

struct mailimf_sender {
  struct mailimf_mailbox * snd_mb; /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_sender * mailimf_sender_new(struct mailimf_mailbox * snd_mb);

LIBETPAN_EXPORT
void mailimf_sender_free(struct mailimf_sender * sender);




/*
  mailimf_reply_to is the parsed Reply-To field

  - rt_addr_list is the parsed address list
 */

struct mailimf_reply_to {
  struct mailimf_address_list * rt_addr_list; /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_reply_to *
mailimf_reply_to_new(struct mailimf_address_list * rt_addr_list);

LIBETPAN_EXPORT
void mailimf_reply_to_free(struct mailimf_reply_to * reply_to);




/*
  mailimf_to is the parsed To field
  
  - to_addr_list is the parsed address list
*/

struct mailimf_to {
  struct mailimf_address_list * to_addr_list; /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_to * mailimf_to_new(struct mailimf_address_list * to_addr_list);

LIBETPAN_EXPORT
void mailimf_to_free(struct mailimf_to * to);




/*
  mailimf_cc is the parsed Cc field

  - cc_addr_list is the parsed addres list
*/

struct mailimf_cc {
  struct mailimf_address_list * cc_addr_list; /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_cc * mailimf_cc_new(struct mailimf_address_list * cc_addr_list);

LIBETPAN_EXPORT
void mailimf_cc_free(struct mailimf_cc * cc);




/*
  mailimf_bcc is the parsed Bcc field

  - bcc_addr_list is the parsed addres list
*/

struct mailimf_bcc {
  struct mailimf_address_list * bcc_addr_list; /* can be NULL */
}

LIBETPAN_EXPORT
struct mailimf_bcc *
mailimf_bcc_new(struct mailimf_address_list * bcc_addr_list);

LIBETPAN_EXPORT
void mailimf_bcc_free(struct mailimf_bcc * bcc);



/*
  mailimf_message_id is the parsed Message-ID field
  
  - mid_value is the message identifier
*/

struct mailimf_message_id {
  char * mid_value; /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_message_id * mailimf_message_id_new(char * mid_value);

LIBETPAN_EXPORT
void mailimf_message_id_free(struct mailimf_message_id * message_id);




/*
  mailimf_in_reply_to is the parsed In-Reply-To field

  - mid_list is the list of message identifers
*/

struct mailimf_in_reply_to {
  clist * mid_list; /* list of (char *), != NULL */
}

LIBETPAN_EXPORT
struct mailimf_in_reply_to * mailimf_in_reply_to_new(clist * mid_list);

LIBETPAN_EXPORT
void mailimf_in_reply_to_free(struct mailimf_in_reply_to * in_reply_to);



/*
  mailimf_references is the parsed References field

  - msg_id_list is the list of message identifiers
 */

struct mailimf_references {
  clist * mid_list; /* list of (char *) */
       /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_references * mailimf_references_new(clist * mid_list);

LIBETPAN_EXPORT
void mailimf_references_free(struct mailimf_references * references);



/*
  mailimf_subject is the parsed Subject field
  
  - sbj_value is the value of the field
*/

struct mailimf_subject {
  char * sbj_value; /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_subject * mailimf_subject_new(char * sbj_value);

LIBETPAN_EXPORT
void mailimf_subject_free(struct mailimf_subject * subject);


/*
  mailimf_comments is the parsed Comments field

  - cm_value is the value of the field
*/

struct mailimf_comments {
  char * cm_value; /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_comments * mailimf_comments_new(char * cm_value);

LIBETPAN_EXPORT
void mailimf_comments_free(struct mailimf_comments * comments);


/*
  mailimf_keywords is the parsed Keywords field

  - kw_list is the list of keywords
*/

struct mailimf_keywords {
  clist * kw_list; /* list of (char *), != NULL */
}

LIBETPAN_EXPORT
struct mailimf_keywords * mailimf_keywords_new(clist * kw_list);

LIBETPAN_EXPORT
void mailimf_keywords_free(struct mailimf_keywords * keywords);


/*
  mailimf_return is the parsed Return-Path field

  - ret_path is the parsed value of Return-Path
*/

struct mailimf_return {
  struct mailimf_path * ret_path; /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_return *
mailimf_return_new(struct mailimf_path * ret_path);

LIBETPAN_EXPORT
void mailimf_return_free(struct mailimf_return * return_path);


/*
  mailimf_path is the parsed value of Return-Path

  - pt_addr_spec is a mailbox
*/

struct mailimf_path {
  char * pt_addr_spec; /* can be NULL */
}

LIBETPAN_EXPORT
struct mailimf_path * mailimf_path_new(char * pt_addr_spec);

LIBETPAN_EXPORT
void mailimf_path_free(struct mailimf_path * path);


/*
  mailimf_optional_field is a non-parsed field

  - fld_name is the name of the field

  - fld_value is the value of the field
*/

struct mailimf_optional_field {
  char * fld_name;  /* != NULL */
  char * fld_value; /* != NULL */
}

LIBETPAN_EXPORT
struct mailimf_optional_field *
mailimf_optional_field_new(char * fld_name, char * fld_value);

LIBETPAN_EXPORT
void mailimf_optional_field_free(struct mailimf_optional_field * opt_field);


/*
  mailimf_fields is the native structure that IMF module will use,
  this module will provide an easier structure to use when parsing fields.

  mailimf_single_fields is an easier structure to get parsed fields,
  rather than iteration over the list of fields

  - fld_orig_date is the parsed "Date" field

  - fld_from is the parsed "From" field
  
  - fld_sender is the parsed "Sender "field

  - fld_reply_to is the parsed "Reply-To" field
  
  - fld_to is the parsed "To" field

  - fld_cc is the parsed "Cc" field

  - fld_bcc is the parsed "Bcc" field

  - fld_message_id is the parsed "Message-ID" field

  - fld_in_reply_to is the parsed "In-Reply-To" field

  - fld_references is the parsed "References" field

  - fld_subject is the parsed "Subject" field
  
  - fld_comments is the parsed "Comments" field

  - fld_keywords is the parsed "Keywords" field
*/

struct mailimf_single_fields {
  struct mailimf_orig_date * fld_orig_date;      /* can be NULL */
  struct mailimf_from * fld_from;                /* can be NULL */
  struct mailimf_sender * fld_sender;            /* can be NULL */
  struct mailimf_reply_to * fld_reply_to;        /* can be NULL */
  struct mailimf_to * fld_to;                    /* can be NULL */
  struct mailimf_cc * fld_cc;                    /* can be NULL */
  struct mailimf_bcc * fld_bcc;                  /* can be NULL */
  struct mailimf_message_id * fld_message_id;    /* can be NULL */
  struct mailimf_in_reply_to * fld_in_reply_to;  /* can be NULL */
  struct mailimf_references * fld_references;    /* can be NULL */
  struct mailimf_subject * fld_subject;          /* can be NULL */
  struct mailimf_comments * fld_comments;        /* can be NULL */
  struct mailimf_keywords * fld_keywords;        /* can be NULL */
}






/* internal use */

void mailimf_atom_free(char * atom);

void mailimf_dot_atom_free(char * dot_atom);

void mailimf_dot_atom_text_free(char * dot_atom);

void mailimf_quoted_string_free(char * quoted_string);

void mailimf_word_free(char * word);

void mailimf_phrase_free(char * phrase);

void mailimf_unstructured_free(char * unstructured);

void mailimf_angle_addr_free(char * angle_addr);

void mailimf_display_name_free(char * display_name);

void mailimf_addr_spec_free(char * addr_spec);

void mailimf_local_part_free(char * local_part);

void mailimf_domain_free(char * domain);

void mailimf_domain_literal_free(char * domain);

void mailimf_msg_id_free(char * msg_id);

void mailimf_id_left_free(char * id_left);

void mailimf_id_right_free(char * id_right);

void mailimf_no_fold_quote_free(char * nfq);

void mailimf_no_fold_literal_free(char * nfl);

void mailimf_field_name_free(char * field_name);



/* these are the possible returned error codes */

enum {
  MAILIMF_NO_ERROR = 0,
  MAILIMF_ERROR_PARSE,
  MAILIMF_ERROR_MEMORY,
  MAILIMF_ERROR_INVAL,
  MAILIMF_ERROR_FILE
}

till mailimf_types.h
+/




























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
