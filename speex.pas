unit speex;
(* speex.pas

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:
   
   - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
   
   - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
   
   - Neither the name of the Xiph.org Foundation nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.
   
   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   -------------------------------------------------------------------------

   The Original Code is speex.pas, realeased 16.06.2005.
   The Initial Developer of the Original Code is ??unknow??.

   Contributor(s):

   modified by Flötenfuchs (c) 2005 ( http://www.xn--fltenfuchs-fcb.de )
   It's free. No guarantees, no warranties!

   modified by Bech (C) 2007 (  http://www.sed-p.net )

   -------------------------------------------------------------------------
   
*)

{$ASSERTIONS ON}  (* for Speex_Load_DLL. you can switch off *)

(* Version of libspeex :
  >= 1.1   : define SPEEX_EX
  <= 1.0.5 : Do NOT define SPEEX_EX
*)
{$DEFINE SPEEX_EX}

interface

uses
  {$IFDEF WIN32}
  Windows
  {$ENDIF}
  {$IFDEF LINUX}
  Types,
  Libc
  {$ENDIF};


const
(** SPEEX_H *******************************************************************)

(* Set enhancement on/off (decoder only) *)
  SPEEX_SET_ENH = 0;
(* Get enhancement state (decoder only) *)
  SPEEX_GET_ENH = 1;

(* Obtain frame size used by encoder/decoder *)
  SPEEX_GET_FRAME_SIZE = 3;
(* Set quality value *)
  SPEEX_SET_QUALITY = 4;
(* Get current quality setting *)
  SPEEX_GET_QUALITY = 5;
(* Set sub-mode to use *)
  SPEEX_SET_MODE = 6;
(* Get current sub-mode in use *)
  SPEEX_GET_MODE = 7;
(* Set low-band sub-mode to use (wideband only) *)
  SPEEX_SET_LOW_MODE = 8;
(* Get current low-band mode in use (wideband only) *)
  SPEEX_GET_LOW_MODE = 9;
(* Set high-band sub-mode to use (wideband only) *)
  SPEEX_SET_HIGH_MODE = 10;
(* Get current high-band mode in use (wideband only) *)
  SPEEX_GET_HIGH_MODE = 11;
(* Set VBR on (1) or off (0) *)
  SPEEX_SET_VBR = 12;
(* Get VBR status (1 for on, 0 for off) *)
  SPEEX_GET_VBR = 13;
(* Set quality value for VBR encoding (0-10) *)
  SPEEX_SET_VBR_QUALITY = 14;
(* Get current quality value for VBR encoding (0-10) *)
  SPEEX_GET_VBR_QUALITY = 15;
(* Set complexity of the encoder (0-10) *)
  SPEEX_SET_COMPLEXITY = 16;
(* Get current complexity of the encoder (0-10) *)
  SPEEX_GET_COMPLEXITY = 17;
(* Set bit-rate used by the encoder (or lower) *)
  SPEEX_SET_BITRATE = 18;
(* Get current bit-rate used by the encoder or decoder *)
  SPEEX_GET_BITRATE = 19;
(* Define a handler function for in-band Speex request *)
  SPEEX_SET_HANDLER = 20;
(* Define a handler function for in-band user-defined request *)
  SPEEX_SET_USER_HANDLER = 22;
(* Set sampling rate used in bit-rate computation *)
  SPEEX_SET_SAMPLING_RATE = 24;
(* Get sampling rate used in bit-rate computation *)
  SPEEX_GET_SAMPLING_RATE = 25;
(* Reset the encoder/decoder memories to zero *)
  SPEEX_RESET_STATE = 26;
(* Get VBR info (mostly used internally) *)
  SPEEX_GET_RELATIVE_QUALITY = 29;
(* Set VAD status (1 for on, 0 for off) *)
  SPEEX_SET_VAD = 30;
(* Get VAD status (1 for on, 0 for off) *)
  SPEEX_GET_VAD = 31;
(* Set Average Bit-Rate (ABR) to n bits per seconds *)
  SPEEX_SET_ABR = 32;
(* Get Average Bit-Rate (ABR) setting (in bps) *)
  SPEEX_GET_ABR = 33;
(* Set DTX status (1 for on, 0 for off) *)
  SPEEX_SET_DTX = 34;
(* Get DTX status (1 for on, 0 for off) *)
  SPEEX_GET_DTX = 35;
(* Set submode encoding in each frame (1 for yes, 0 for no, setting to no breaks the standard) *)
  SPEEX_SET_SUBMODE_ENCODING = 36;
(* Get submode encoding in each frame *)
  SPEEX_GET_SUBMODE_ENCODING = 37;
(* Returns the lookahead used by Speex *)
  SPEEX_GET_LOOKAHEAD = 39;
(* Sets tuning for packet-loss concealment (expected loss rate) *)
  SPEEX_SET_PLC_TUNING = 40;
(* Gets tuning for PLC *)
  SPEEX_GET_PLC_TUNING = 41;
(* Sets the max bit-rate allowed in VBR mode *)
  SPEEX_SET_VBR_MAX_BITRATE = 42;
(* Gets the max bit-rate allowed in VBR mode *)
  SPEEX_GET_VBR_MAX_BITRATE = 43;
(* Turn on/off input/output high-pass filtering *)
  SPEEX_SET_HIGHPASS = 44;
(* Get status of input/output high-pass filtering *)
  SPEEX_GET_HIGHPASS = 45;

(* Preserving compatibility:*)
(* Equivalent to SPEEX_SET_ENH *)
  SPEEX_SET_PF = 0;
(* Equivalent to SPEEX_GET_ENH *)
  SPEEX_GET_PF = 1;

(* Values allowed for mode queries *)
(* Query the frame size of a mode *)
  SPEEX_MODE_FRAME_SIZE = 0;
(* Query the size of an encoded frame for a particular sub-mode *)
  SPEEX_SUBMODE_BITS_PER_FRAME = 1;

(* Get major Speex version *)
  SPEEX_LIB_GET_MAJOR_VERSION = 1;
(* Get minor Speex version *)
  SPEEX_LIB_GET_MINOR_VERSION = 3;
(* Get micro Speex version *)
  SPEEX_LIB_GET_MICRO_VERSION = 5;
(* Get extra Speex version *)
  SPEEX_LIB_GET_EXTRA_VERSION = 7;
(* Get Speex version string *)
  SPEEX_LIB_GET_VERSION_STRING = 9;

(* Number of defined modes in Speex *)
  SPEEX_NB_MODES = 3;
(* modeID for the defined narrowband mode *)
  SPEEX_MODEID_NB = 0;
(* modeID for the defined wideband mode *)
  SPEEX_MODEID_WB = 1;
(* modeID for the defined ultra-wideband mode *)
  SPEEX_MODEID_UWB = 2;

(** SPEEX_CALLBACKS_H *********************************************************)

(* Total number of callbacks *)
  SPEEX_MAX_CALLBACKS = 16;

(* Describes all the in-band requests *)

(*These are 1-bit requests*)
(* Request for perceptual enhancement (1 for on, 0 for off) *)
  SPEEX_INBAND_ENH_REQUEST = 0;
(* Reserved *)
  SPEEX_INBAND_RESERVED1 = 1;

(*These are 4-bit requests*)
(* Request for a mode change *)
  SPEEX_INBAND_MODE_REQUEST = 2;
(* Request for a low mode change *)
  SPEEX_INBAND_LOW_MODE_REQUEST = 3;
(* Request for a high mode change *)
  SPEEX_INBAND_HIGH_MODE_REQUEST = 4;
(* Request for VBR (1 on, 0 off) *)
  SPEEX_INBAND_VBR_QUALITY_REQUEST = 5;
(* Request to be sent acknowledge *)
  SPEEX_INBAND_ACKNOWLEDGE_REQUEST = 6;
(* Request for VBR (1 for on, 0 for off) *)
  SPEEX_INBAND_VBR_REQUEST = 7;

(*These are 8-bit requests*)
(* Send a character in-band *)
  SPEEX_INBAND_CHAR = 8;
(* Intensity stereo information *)
  SPEEX_INBAND_STEREO = 9;

(*These are 16-bit requests*)
(* Transmit max bit-rate allowed *)
  SPEEX_INBAND_MAX_BITRATE = 10;

(*These are 32-bit requests*)
(* Acknowledge packet reception *)
  SPEEX_INBAND_ACKNOWLEDGE = 12;

(** SPEEX_HEADER_H ************************************************************)

  SPEEX_HEADER_STRING_LENGTH = 8;

(* Maximum number of characters for encoding the Speex version number
   in the header *)
  SPEEX_HEADER_VERSION_LENGTH = 20;

{$IFDEF SPEEX_EX}
(** SPEEX_ECHO_H **************************************************************)

(* Obtain frame size used by the AEC *)
  SPEEX_ECHO_GET_FRAME_SIZE = 3;
(* Set sampling rate *)
  SPEEX_ECHO_SET_SAMPLING_RATE = 24;
(* Get sampling rate *)
  SPEEX_ECHO_GET_SAMPLING_RATE = 25;

(** SPEEX_JITTER_H ************************************************************)

  JITTER_BUFFER_OK = 0;
  JITTER_BUFFER_MISSING = 1;
  JITTER_BUFFER_INCOMPLETE = 2;
  JITTER_BUFFER_INTERNAL_ERROR = -1;
  JITTER_BUFFER_BAD_ARGUMENT = -2;

(** SPEEX_PREPROCESS_H ********************************************************)

(* Set preprocessor denoiser state *)
  SPEEX_PREPROCESS_SET_DENOISE = 0;
(* Get preprocessor denoiser state *)
  SPEEX_PREPROCESS_GET_DENOISE = 1;
(* Set preprocessor Automatic Gain Control state *)
  SPEEX_PREPROCESS_SET_AGC = 2;
(* Get preprocessor Automatic Gain Control state *)
  SPEEX_PREPROCESS_GET_AGC = 3;
(* Set preprocessor Voice Activity Detection state *)
  SPEEX_PREPROCESS_SET_VAD = 4;
(* Get preprocessor Voice Activity Detection state *)
  SPEEX_PREPROCESS_GET_VAD = 5;
(* Set preprocessor Automatic Gain Control level *)
  SPEEX_PREPROCESS_SET_AGC_LEVEL = 6;
(* Get preprocessor Automatic Gain Control level *)
  SPEEX_PREPROCESS_GET_AGC_LEVEL = 7;
(* Set preprocessor dereverb state *)
  SPEEX_PREPROCESS_SET_DEREVERB = 8;
(* Get preprocessor dereverb state *)
  SPEEX_PREPROCESS_GET_DEREVERB = 9;
(* Set preprocessor dereverb level *)
  SPEEX_PREPROCESS_SET_DEREVERB_LEVEL = 10;
(* Get preprocessor dereverb level *)
  SPEEX_PREPROCESS_GET_DEREVERB_LEVEL = 11;
(* Set preprocessor dereverb decay *)
  SPEEX_PREPROCESS_SET_DEREVERB_DECAY = 12;
(* Get preprocessor dereverb decay *)
  SPEEX_PREPROCESS_GET_DEREVERB_DECAY = 13;

  SPEEX_PREPROCESS_SET_PROB_START = 14;
  SPEEX_PREPROCESS_GET_PROB_START = 15;
  SPEEX_PREPROCESS_SET_PROB_CONTINUE = 16;
  SPEEX_PREPROCESS_GET_PROB_CONTINUE = 17;
{$ENDIF}

type
(** SPEEX_H *******************************************************************)

(* Struct defining a Speex mode
   typedef struct SpeexMode {...} *)
  TSpeexMode = record
    mode: Pointer;
    query: Pointer; // MODE_QUERY_FUNC;
    modeName: PChar;
    modeID: Integer;
    bitstream_version: Integer;
    enc_init: Pointer; // ENCODER_INIT_FUNC;
    enc_destroy: Pointer; // ENCODER_DESTROY_FUNC;
    enc: Pointer; // ENCODE_FUNC;
    dec_init: Pointer; // DECODER_INIT_FUNC;
    dec_destroy: Pointer; // DECODER_DESTROY_FUNC;
    dec: Pointer; // DECODE_FUNC;
    enc_ctl: Pointer; // ENCODER_CTL_FUNC;
    dec_ctl: Pointer; // DECODER_CTL_FUNC;
  end;
  PSpeexMode = ^TSpeexMode;

  PSpeexState = Pointer; (* " void *state " *)

(** SPEEX_BITS_H **************************************************************)

(* Bit-packing data structure representing (part of) a bit-stream.
   typedef struct SpeexBits {...} *)
  TSpeexBits = record
    bytes: PChar;       (*< "raw" data *)
    nbBits: Integer;    (*< Total number of bits stored in the stream*)
    bytePtr: Integer;   (*< Position of the byte "cursor" *)
    bitPtr: Integer;    (*< Position of the bit "cursor" within the current char *)
    owner: Integer;     (*< Does the struct "own" the "raw" buffer (member "chars") *)
    overflow: Integer;  (*< Set to one if we try to read past the valid data *)
    buf_size: Integer;  (*< Allocated size for buffer *)
    reserved1: Integer; (*< Reserved for future use *)
    reserved2: Pointer; (*< Reserved for future use *)
  end;
  PSpeexBits = ^TSpeexBits;

(** SPEEX_CALLBACKS_H *********************************************************)

(* Callback function type *)
  speex_callback_func = function(bits: PSpeexBits; state: PSpeexState;
     data : Pointer): Integer; cdecl;

(* Callback information *)
  TSpeexCallback = record
   callback_id : Integer;         (*< ID associated to the callback *)
   func : speex_callback_func;    (*< Callback handler function *)
   data : Pointer;                (*< Data that will be sent to the handler *)
   reserved1 : Pointer;           (*< Reserved for future use *)
   reserved2 : Integer;           (*< Reserved for future use *)
  end;
  PSpeexCallback = ^TSpeexCallback;

(** SPEEX_HEADER_H ************************************************************)

  TSpeexHeader = record
   speex_string: array [0..SPEEX_HEADER_STRING_LENGTH-1] of char; (*< Identifies a Speex bit-stream, always set to "Speex   " *)
   speex_version: array [0..SPEEX_HEADER_VERSION_LENGTH-1] of char; (*< Speex version *)
   speex_version_id : Integer;       (*< Version for Speex (for checking compatibility) *)
   header_size : Integer;            (*< Total size of the header ( sizeof(SpeexHeader) ) *)
   rate : Integer;                   (*< Sampling rate used *)
   mode : Integer;                   (*< Mode used (0 for narrowband, 1 for wideband) *)
   mode_bitstream_version : Integer; (*< Version ID of the bit-stream *)
   nb_channels : Integer;            (*< Number of channels encoded *)
   bitrate : Integer;                (*< Bit-rate used *)
   frame_size : Integer;             (*< Size of frames *)
   vbr : Integer;                    (*< 1 for a VBR encoding, 0 otherwise *)
   frames_per_packet : Integer;      (*< Number of frames stored per Ogg packet *)
   extra_headers : Integer;          (*< Number of additional headers after the comments *)
   reserved1 : Integer;              (*< Reserved for future use, must be zero *)
   reserved2 : Integer;              (*< Reserved for future use, must be zero *)
  end;
  PSpeexHeader = ^TSpeexHeader;

(** SPEEX_STEREO_H ************************************************************)

(* State used for decoding (intensity) stereo information *)
  TSpeexStereoState = record
   balance : single;         (*< Left/right balance info *)
   e_ratio : single;         (*< Ratio of energies: E(left+right)/[E(left)+E(right)]  *)
   smooth_left : single;     (*< Smoothed left channel gain *)
   smooth_right : single;    (*< Smoothed right channel gain *)
   reserved1 : single;       (*< Reserved for future use *)
   reserved2 : single;       (*< Reserved for future use *)
  end;
  PSpeexStereoState = ^TSpeexStereoState;

{$IFDEF SPEEX_EX}
(** SPEEX_ECHO_H **************************************************************)

(* struct drft_lookup; struct SpeexEchoState_;
   typedef struct SpeexEchoState_ SpeexEchoState; *)
  PSpeexEchoState = Pointer;

(** SPEEX_JITTER_H ************************************************************)

  TJitterBuffer = record
   data: PChar;
   len: Longword;
   timestamp: Longword;
   span: Longword;
  end;
  PJitterBuffer = ^TJitterBuffer;

(* Speex jitter-buffer state. *)
  TSpeexJitter = record
   current_packet: TSpeexBits;       (*< Current Speex packet                *)
   valid_bits: Integer;              (*< True if Speex bits are valid        *)
   packets : PJitterBuffer;
   dec: Pointer;                     (*< Pointer to Speex decoder            *)
   frame_size: Integer;              (*< Frame size of Speex decoder         *)
  end;
  PSpeexJitter = ^TSpeexJitter;

(** SPEEX_PREPROCESS_H ********************************************************)

(* Speex pre-processor state.
   typedef struct SpeexPreprocessState {...} *)
  PSpeexPreprocessState = Pointer;
{$ENDIF}

var
(** SPEEX_H *******************************************************************)

(* Returns a handle to a newly created Speex encoder state structure *)
  speex_encoder_init: function(mode: PSpeexMode): Pointer cdecl;
(* Frees all resources associated to an existing Speex encoder state. *)
  speex_encoder_destroy: procedure(state: PSpeexState) cdecl;
(* Uses an existing encoder state to encode one frame of speech pointed to by
    "in". The encoded bit-stream is saved in "bits". *)
  speex_encode: function(state: PSpeexState; in_:PSingle;
    bits: PSpeexBits): Integer cdecl;
{$IFDEF SPEEX_EX}
(* Uses an existing encoder state to encode one frame of speech pointed to by
    "in". The encoded bit-stream is saved in "bits". *)
  speex_encode_int: function(state: PSpeexState; in_:PSmallInt;
    bits: PSpeexBits): Integer cdecl;
{$ENDIF}
(* Used like the ioctl function to control the encoder parameters *)
  speex_encoder_ctl: function(state: PSpeexState; request: Integer;
    ptr: Pointer): Integer cdecl;
(* Returns a handle to a newly created decoder state structure. *)
  speex_decoder_init: function(mode: PSpeexMode): Pointer cdecl;
(* Frees all resources associated to an existing decoder state. *)
  speex_decoder_destroy: procedure(state: PSpeexState) cdecl;
(* Uses an existing decoder state to decode one frame of speech from
 * bit-stream bits. The output speech is saved written to out. *)
  speex_decode: function(state: PSpeexState; bits: PSpeexBits;
    out_: PSingle): Integer cdecl;
{$IFDEF SPEEX_EX}
(* Uses an existing decoder state to decode one frame of speech from
 * bit-stream bits. The output speech is saved written to out. *)
  speex_decode_int: function(state: PSpeexState; bits: PSpeexBits;
    out_: PSmallInt): Integer cdecl;
{$ENDIF}
(* Used like the ioctl function to control the encoder parameters *)
  speex_decoder_ctl: function(state: PSpeexState; request: Integer;
    ptr: Pointer): Integer cdecl;
(* Query function for mode information *)
  speex_mode_query: function(var mode: PSpeexMode; request: Integer;
    ptr: Pointer): Integer cdecl;
(* Functions for controlling the behavior of libspeex *)
  speex_lib_ctl: function(request: Integer; 
    ptr: Pointer): Integer cdecl;
(* Obtain one of the modes available *)
  speex_lib_get_mode: function(mode : Integer): PSpeexMode; cdecl;

(** SPEEX_BITS_H **************************************************************)

(* Initializes and allocates resources for a SpeexBits struct *)
  speex_bits_init: procedure(bits: PSpeexBits) cdecl;
(* Initializes SpeexBits struct using a pre-allocated buffer *)
  speex_bits_init_buffer: procedure(bits: PSpeexBits; buff: Pointer;
    buf_size: Integer) cdecl;
(* Frees all resources associated to a SpeexBits struct. Right now this does
   nothing since no resources are allocated, but this could change in the future. *)
  speex_bits_destroy: procedure(bits: PSpeexBits) cdecl;
(* Resets bits to initial value (just after initialization, erasing content) *)
  speex_bits_reset: procedure(bits: PSpeexBits) cdecl;
(* Rewind the bit-stream to the beginning (ready for read) without erasing the content *)
  speex_bits_rewind: procedure(bits: PSpeexBits) cdecl;
(* Initializes the bit-stream from the data in an area of memory *)
  speex_bits_read_from: procedure(bits: PSpeexBits; bytes: PChar;
    len: Integer) cdecl;
(* Append bytes to the bit-stream *)
  speex_bits_read_whole_bytes: procedure(bits: PSpeexBits; bytes: PChar;
    len: Integer) cdecl;
(* Write the content of a bit-stream to an area of memory *)
  speex_bits_write: function(bits: PSpeexBits; bytes: PChar;
    max_len: Integer): Integer cdecl;
(* Like speex_bits_write, but writes only the complete bytes in the stream.
   Also removes the written bytes from the stream *)
  speex_bits_write_whole_bytes: function(bits: PSpeexBits; bytes: PChar;
    max_len: Integer): Integer cdecl;
(* Append bits to the bit-stream *)
  speex_bits_pack: procedure(bits: PSpeexBits; data: Integer;
    nbBits: Integer) cdecl;
(* Interpret the next bits in the bit-stream as a signed integer *)
  speex_bits_unpack_signed: function(bits: PSpeexBits;
    nbBits: Integer): Integer cdecl;
(* Interpret the next bits in the bit-stream as an unsigned integer *)
  speex_bits_unpack_unsigned: function(bits: PSpeexBits;
    nbBits: Integer): Word cdecl;
(* Returns the number of bytes in the bit-stream, including the last one even
   if it is not "full" *)
  speex_bits_nbytes: function(bits: PSpeexBits): Integer cdecl;
(* Same as speex_bits_unpack_unsigned, but without modifying the cursor position *)
  speex_bits_peek_unsigned: function(bits: PSpeexBits;
    nbBits: Integer): Word cdecl;
(* Get the value of the next bit in the stream, without modifying the "cursor" position *)
  speex_bits_peek: function(bits: PSpeexBits): Integer cdecl;
(* Advances the position of the "bit cursor" in the stream *)
  speex_bits_advance: procedure(bits: PSpeexBits; n: Integer) cdecl;
(* Returns the number of bits remaining to be read in a stream *)
  speex_bits_remaining: function(bits: PSpeexBits): Integer cdecl;
(* Insert a terminator so that the data can be sent as a packet while
   auto-detecting the number of frames in each packet *)
  speex_bits_insert_terminator: procedure(bits: PSpeexBits) cdecl;

(** SPEEX_CALLBACKS_H *********************************************************)

(* Handle in-band request *)
  speex_inband_handler: Function(bits: PSpeexBits; callback_list : PSpeexCallback;
  state: PSpeexState): Integer cdecl;
(* Standard handler for mode request (change mode, no questions asked) *)
  speex_std_mode_request_handler: Function(bits: PSpeexBits; callback_list : PSpeexCallback;
  state: PSpeexState): Integer cdecl;
(* Standard handler for high mode request (change high mode, no questions asked) *)
  speex_std_high_mode_request_handler: Function(bits: PSpeexBits; callback_list : PSpeexCallback;
    state: PSpeexState): Integer cdecl;
(* Standard handler for in-band characters (write to stderr) *)
  speex_std_char_handler: Function(bits: PSpeexBits; callback_list : PSpeexCallback;
    state: PSpeexState): Integer cdecl;
(* Default handler for user-defined requests: in this case, just ignore *)
  speex_default_user_handler: Function(bits: PSpeexBits; callback_list : PSpeexCallback;
    state: PSpeexState): Integer cdecl;
    
  speex_std_low_mode_request_handler: Function(bits: PSpeexBits; callback_list : PSpeexCallback;
    state: PSpeexState): Integer cdecl;
  speex_std_vbr_request_handler: Function(bits: PSpeexBits; callback_list : PSpeexCallback;
    state: PSpeexState): Integer cdecl;
  speex_std_enh_request_handler: Function(bits: PSpeexBits; callback_list : PSpeexCallback;
    state: PSpeexState): Integer cdecl;
  speex_std_vbr_quality_request_handler: Function(bits: PSpeexBits; callback_list : PSpeexCallback;
    state: PSpeexState): Integer cdecl;

(** SPEEX_HEADER_H ************************************************************)

(* Initializes a SpeexHeader using basic information *)
  speex_init_header: Procedure(header: PSpeexHeader; rate, nb_channels : Integer;
    m : PSpeexmode) cdecl;
(* Creates the header packet from the header itself (mostly involves endianness conversion) *)
  speex_header_to_packet: Function(header: PSpeexHeader; size: PInteger): Pchar cdecl;
(* Creates a SpeexHeader from a packet *)
  speex_packet_to_header: Function(header: PSpeexHeader; size: Integer): PSpeexheader cdecl;

(** SPEEX_STEREO_H ************************************************************)

(* Transforms a stereo frame into a mono frame and stores intensity stereo info in 'bits' *)
  speex_encode_stereo: Procedure(data: PSingle; frame_size: Integer;
     bits: PSpeexBits) cdecl;
{$IFDEF SPEEX_EX}
(* Transforms a stereo frame into a mono frame and stores intensity stereo info in 'bits' (int version) *)
  speex_encode_stereo_int: Procedure(data: PSmallint; frame_size: Integer;
     bits: PSpeexBits) cdecl;
{$ENDIF}
(* Transforms a mono frame into a stereo frame using intensity stereo info *)
  speex_decode_stereo: Procedure(data: PSingle; frame_size: Integer;
     stereo: PSpeexStereoState) cdecl;
{$IFDEF SPEEX_EX}
(* Transforms a mono frame into a stereo frame using intensity stereo info (int version) *)
  speex_decode_stereo_int: Procedure(data: PSmallint; frame_size: Integer;
     stereo: PSpeexStereoState) cdecl;
{$ENDIF}
(* Callback handler for intensity stereo info *)
  speex_std_stereo_request_handler: Function(bits: PSpeexBits;
     stereo: PSpeexStereoState; data: Pointer): Integer cdecl;

{$IFDEF SPEEX_EX}
(** SPEEX_ECHO_H **************************************************************)

(* Creates a new echo canceller state *)
  speex_echo_state_init: function(frame_size, filter_length: Integer) : PSpeexEchoState cdecl;
(* Destroys an echo canceller state *)
  speex_echo_state_destroy: procedure(st: PSpeexEchoState) cdecl;
(* Performs echo cancellation a frame *)
  speex_echo_cancel: procedure(st: PSpeexEchoState; rec, play, _out: PSmallInt; Yout: PLongInt) cdecl;
(* Reset the echo canceller state *)
  speex_echo_state_reset: procedure(st: PSpeexEchoState) cdecl;

(** SPEEX_JITTER_H ************************************************************)

(* Initialise jitter buffer *)
  speex_jitter_init: Procedure(jitter: PSpeexJitter; decoder: Pointer;
     sampling_rate: Integer) cdecl;
(* Destroy jitter buffer *)
  speex_jitter_destroy: Procedure(jitter: PSpeexJitter) cdecl;
(* Put one packet into the jitter buffer *)
  speex_jitter_put: Procedure(jitter: PSpeexJitter; packet: PChar;
     len, timestamp : Integer) cdecl;
(* Get one packet from the jitter buffer *)
  speex_jitter_get: Procedure(jitter: PSpeexJitter; out_ :PSmallint;
     start_offset: PInteger) cdecl;
(* Get pointer timestamp of jitter buffer *)
  speex_jitter_get_pointer_timestamp: Function(jitter: PSpeexJitter): Integer cdecl;

(** SPEEX_PREPROCESS_H ********************************************************)

(* Creates a new preprocessing state *)
  speex_preprocess_state_init: function(frame_size : Integer;
    sampling_rate : Integer): PSpeexPreprocessState cdecl;
(* Destroys a denoising state *)
  speex_preprocess_state_destroy: procedure(st : PSpeexPreprocessState) cdecl;
(* Preprocess a frame *)
  speex_preprocess_run: function(st : PSpeexPreprocessState; x : PSmallInt): Integer cdecl;
(* Preprocess a frame - DEPRECATED *)
  speex_preprocess: function(st : PSpeexPreprocessState; x : PSmallInt;
    echo : PLongInt): Integer cdecl;
(* Update preprocessor state, but do not compute the output *)
  speex_preprocess_estimate_update: procedure(st : PSpeexPreprocessState;
    x : PSmallInt; echo : PLongInt) cdecl;
(* Used like the ioctl function to control the preprocessor parameters *)
  speex_preprocess_ctl: function(st : PSpeexPreprocessState; request : Integer;
    ptr: Pointer): Integer cdecl;
{$ENDIF}

var
  speex_DLL_Loaded: Boolean = False;

procedure Speex_Load_DLL;

implementation

const
{$IFDEF WIN32}
  SPEEXDLLName: PChar = 'libspeex.dll';
{$ENDIF}
{$IFDEF LINUX}
  SPEEXDLLName: PChar = 'libspeex.so';
{$ENDIF}

var
  DLLHandle: {$IFDEF WIN32}THandle{$ENDIF}{$IFDEF LINUX}HMODULE{$ENDIF};

procedure Speex_Load_DLL;

 function connectProc(var ProcAdr:pointer; ProcName:AnsiString):boolean;
 begin
  ProcAdr := nil;
  try
    ProcAdr := GetProcAddress(DLLHandle, PChar(ProcName));
    Assert(Assigned(ProcAdr), SPEEXDLLName + ' - Could not find method: '+ProcName);
  finally
    Result := Assigned(ProcAdr);
  end;
 end;

begin
  if speex_DLL_Loaded then Exit;

  DLLHandle := LoadLibrary(SPEEXDLLName);
  if DLLHandle <> 0 then
  begin
    speex_DLL_Loaded := True;

(** SPEEX_H *******************************************************************)
    connectProc(@speex_encoder_init, 'speex_encoder_init');
    connectProc(@speex_encoder_destroy, 'speex_encoder_destroy');
    connectProc(@speex_encode, 'speex_encode');
{$IFDEF SPEEX_EX}
    connectProc(@speex_encode_int, 'speex_encode_int');
{$ENDIF}
    connectProc(@speex_encoder_ctl, 'speex_encoder_ctl');

    connectProc(@speex_decoder_init, 'speex_decoder_init');
    connectProc(@speex_decoder_destroy, 'speex_decoder_destroy');
    connectProc(@speex_decode, 'speex_decode');
{$IFDEF SPEEX_EX}
    connectProc(@speex_decode_int, 'speex_decode_int');
{$ENDIF}
    connectProc(@speex_decoder_ctl, 'speex_decoder_ctl');
    
    connectProc(@speex_mode_query, 'speex_mode_query');
    connectProc(@speex_lib_ctl, 'speex_lib_ctl');
    connectProc(@speex_lib_get_mode, 'speex_lib_get_mode');

(** SPEEX_BITS_H **************************************************************)

    connectProc(@speex_bits_init, 'speex_bits_init');
    connectProc(@speex_bits_init_buffer, 'speex_bits_init_buffer');
    connectProc(@speex_bits_destroy, 'speex_bits_destroy');
    connectProc(@speex_bits_reset, 'speex_bits_reset');
    connectProc(@speex_bits_rewind, 'speex_bits_rewind');
    connectProc(@speex_bits_read_from, 'speex_bits_read_from');
    connectProc(@speex_bits_read_whole_bytes, 'speex_bits_read_whole_bytes');
    connectProc(@speex_bits_write, 'speex_bits_write');
    connectProc(@speex_bits_write_whole_bytes, 'speex_bits_write_whole_bytes');
    connectProc(@speex_bits_pack, 'speex_bits_pack');
    connectProc(@speex_bits_unpack_signed, 'speex_bits_unpack_signed');
    connectProc(@speex_bits_unpack_unsigned, 'speex_bits_unpack_unsigned');
    connectProc(@speex_bits_nbytes, 'speex_bits_nbytes');
    connectProc(@speex_bits_peek_unsigned, 'speex_bits_peek_unsigned');
    connectProc(@speex_bits_peek, 'speex_bits_peek');
    connectProc(@speex_bits_advance, 'speex_bits_advance');
    connectProc(@speex_bits_remaining, 'speex_bits_remaining');
    connectProc(@speex_bits_insert_terminator, 'speex_bits_insert_terminator');

(** SPEEX_CALLBACKS_H *********************************************************)

    connectProc(@speex_inband_handler, 'speex_inband_handler');
    connectProc(@speex_std_mode_request_handler, 'speex_std_mode_request_handler');
    connectProc(@speex_std_high_mode_request_handler, 'speex_std_high_mode_request_handler');
    connectProc(@speex_std_char_handler, 'speex_std_char_handler');
    connectProc(@speex_default_user_handler, 'speex_default_user_handler');
    connectProc(@speex_std_low_mode_request_handler, 'speex_std_low_mode_request_handler');
    connectProc(@speex_std_vbr_request_handler, 'speex_std_vbr_request_handler');
    connectProc(@speex_std_enh_request_handler, 'speex_std_enh_request_handler');
    connectProc(@speex_std_vbr_quality_request_handler, 'speex_std_vbr_quality_request_handler');

(** SPEEX_HEADER_H ************************************************************)

    connectProc(@speex_init_header, 'speex_init_header');
    connectProc(@speex_header_to_packet, 'speex_header_to_packet');
    connectProc(@speex_packet_to_header, 'speex_packet_to_header');

(** SPEEX_STEREO_H ************************************************************)

    connectProc(@speex_encode_stereo, 'speex_encode_stereo');
{$IFDEF SPEEX_EX}
    connectProc(@speex_encode_stereo_int, 'speex_encode_stereo_int');
{$ENDIF}
    connectProc(@speex_decode_stereo, 'speex_decode_stereo');
{$IFDEF SPEEX_EX}
    connectProc(@speex_decode_stereo_int, 'speex_decode_stereo_int');
{$ENDIF}
    connectProc(@speex_std_stereo_request_handler, 'speex_std_stereo_request_handler');

{$IFDEF SPEEX_EX}
(** SPEEX_ECHO_H **************************************************************)

    connectProc(@speex_echo_state_init, 'speex_echo_state_init');
    connectProc(@speex_echo_state_destroy, 'speex_echo_state_destroy');
    connectProc(@speex_echo_cancel, 'speex_echo_cancel');
    connectProc(@speex_echo_state_reset, 'speex_echo_state_reset');

(** SPEEX_JITTER_H ************************************************************)

    connectProc(@speex_jitter_init, 'speex_jitter_init');
    connectProc(@speex_jitter_destroy, 'speex_jitter_destroy');
    connectProc(@speex_jitter_put, 'speex_jitter_put');
    connectProc(@speex_jitter_get, 'speex_jitter_get');
    connectProc(@speex_jitter_get_pointer_timestamp, 'speex_jitter_get_pointer_timestamp');

(** SPEEX_PREPROCESS_H ********************************************************)

    connectProc(@speex_preprocess_state_init, 'speex_preprocess_state_init');
    connectProc(@speex_preprocess_state_destroy, 'speex_preprocess_state_destroy');
    connectProc(@speex_preprocess, 'speex_preprocess_run');
    connectProc(@speex_preprocess, 'speex_preprocess');
    connectProc(@speex_preprocess_estimate_update, 'speex_preprocess_estimate_update');
    connectProc(@speex_preprocess_ctl, 'speex_preprocess_ctl');
{$ENDIF}

  end
  else
  begin
    speex_DLL_Loaded := False;
  end;
  
  Assert(speex_DLL_Loaded, 'Error: libspeex ('+SPEEXDLLName+') could not be loaded !!');
end {LoadDLL};

Initialization
  DLLHandle := 0;

finalization
  if DLLHandle <> 0 then FreeLibrary(DLLHandle);

end.