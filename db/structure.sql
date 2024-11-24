SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
--SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pg_search_dmetaphone(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.pg_search_dmetaphone(text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  SELECT array_to_string(ARRAY(SELECT dmetaphone(unnest(regexp_split_to_array($1, E'\\s+')))), ' ')
$_$;


SET default_tablespace = '';

--
-- Name: action_text_rich_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.action_text_rich_texts (
    id bigint NOT NULL,
    name character varying NOT NULL,
    body text,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.action_text_rich_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.action_text_rich_texts_id_seq OWNED BY public.action_text_rich_texts.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp without time zone NOT NULL,
    service_name character varying NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id bigint NOT NULL,
    building_id bigint NOT NULL,
    is_primary boolean DEFAULT false,
    house_number character varying,
    prefix character varying,
    name character varying,
    suffix character varying,
    city character varying,
    postal_code character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    year integer
);


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- Name: annotations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.annotations (
    id bigint NOT NULL,
    annotation_text text,
    map_overlay_id bigint,
    building_id bigint
);


--
-- Name: annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.annotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.annotations_id_seq OWNED BY public.annotations.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: architects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.architects (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: architects_buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.architects_buildings (
    architect_id integer NOT NULL,
    building_id integer NOT NULL
);


--
-- Name: architects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.architects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: architects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.architects_id_seq OWNED BY public.architects.id;


--
-- Name: audios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audios (
    id bigint NOT NULL,
    created_by_id bigint NOT NULL,
    reviewed_by_id bigint,
    reviewed_at timestamp(6) without time zone,
    description text,
    notes text,
    caption text,
    creator character varying,
    date_type integer,
    date_text character varying,
    date_start date,
    date_end date,
    location character varying,
    identifier character varying,
    latitude numeric,
    longitude numeric,
    duration integer,
    file_size integer,
    processed_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    remote_url character varying
);


--
-- Name: audios_buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audios_buildings (
    audio_id bigint,
    building_id bigint
);


--
-- Name: audios_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audios_id_seq OWNED BY public.audios.id;


--
-- Name: audios_people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audios_people (
    person_id bigint,
    audio_id bigint
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id bigint NOT NULL,
    loggable_type character varying,
    loggable_id integer,
    user_id bigint,
    message character varying,
    logged_at timestamp(6) without time zone
);


--
-- Name: audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_logs_id_seq OWNED BY public.audit_logs.id;


--
-- Name: building_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.building_types (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: building_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.building_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: building_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.building_types_id_seq OWNED BY public.building_types.id;


--
-- Name: buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buildings (
    id integer NOT NULL,
    name character varying NOT NULL,
    city character varying,
    state character varying,
    postal_code character varying,
    year_earliest integer,
    year_latest integer,
    building_type_id integer,
    description text,
    lat numeric(15,10),
    lon numeric(15,10),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    year_earliest_circa boolean DEFAULT false,
    year_latest_circa boolean DEFAULT false,
    address_house_number character varying,
    address_street_prefix character varying,
    address_street_name character varying,
    address_street_suffix character varying,
    stories double precision,
    annotations_legacy text,
    lining_type_id integer,
    frame_type_id integer,
    block_number character varying,
    created_by_id integer,
    reviewed_by_id integer,
    reviewed_at timestamp without time zone,
    investigate boolean DEFAULT false,
    investigate_reason character varying,
    notes text,
    locality_id bigint,
    building_types_mask integer,
    parent_id bigint,
    hive_year integer
);


--
-- Name: buildings_building_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buildings_building_types (
    building_id bigint,
    building_type_id bigint
);


--
-- Name: buildings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.buildings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: buildings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.buildings_id_seq OWNED BY public.buildings.id;


--
-- Name: buildings_narratives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buildings_narratives (
    building_id bigint,
    narrative_id bigint
);


--
-- Name: buildings_photographs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buildings_photographs (
    photograph_id bigint NOT NULL,
    building_id bigint NOT NULL
);


--
-- Name: buildings_videos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buildings_videos (
    building_id bigint,
    video_id bigint
);


--
-- Name: bulk_updated_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bulk_updated_records (
    id bigint NOT NULL,
    bulk_update_id bigint,
    record_type character varying,
    record_id bigint
);


--
-- Name: bulk_updated_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bulk_updated_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bulk_updated_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bulk_updated_records_id_seq OWNED BY public.bulk_updated_records.id;


--
-- Name: bulk_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bulk_updates (
    id bigint NOT NULL,
    year integer,
    field character varying,
    value_from character varying,
    value_to character varying,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: bulk_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bulk_updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bulk_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bulk_updates_id_seq OWNED BY public.bulk_updates.id;


--
-- Name: census_1850_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_1850_records (
    id bigint NOT NULL,
    locality_id bigint,
    building_id bigint,
    person_id bigint,
    created_by_id bigint,
    reviewed_by_id bigint,
    reviewed_at timestamp without time zone,
    page_number integer,
    page_side character varying(1),
    line_number integer,
    county character varying,
    city character varying,
    institution_name character varying,
    institution_type character varying,
    state character varying,
    ward integer,
    street_house_number character varying,
    street_prefix character varying,
    street_name character varying,
    street_suffix character varying,
    apartment_number character varying,
    dwelling_number character varying,
    family_id character varying,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    name_prefix character varying,
    name_suffix character varying,
    age integer,
    age_months integer,
    sex character varying,
    race character varying,
    occupation character varying DEFAULT 'None'::character varying,
    home_value integer,
    pob character varying,
    just_married boolean,
    attended_school boolean,
    cannot_read_write boolean,
    deaf_dumb boolean,
    blind boolean,
    insane boolean,
    idiotic boolean,
    pauper boolean,
    convict boolean,
    nature_of_misfortune character varying,
    year_of_misfortune integer,
    notes text,
    foreign_born boolean DEFAULT false,
    taker_error boolean DEFAULT false,
    farm_schedule integer,
    searchable_name text,
    histid uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    sortable_name character varying
);


--
-- Name: census_1850_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_1850_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_1850_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_1850_records_id_seq OWNED BY public.census_1850_records.id;


--
-- Name: census_1860_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_1860_records (
    id bigint NOT NULL,
    locality_id bigint,
    building_id bigint,
    person_id bigint,
    created_by_id bigint,
    reviewed_by_id bigint,
    reviewed_at timestamp without time zone,
    page_number integer,
    page_side character varying(1),
    line_number integer,
    county character varying,
    city character varying,
    post_office character varying,
    institution_name character varying,
    institution_type character varying,
    state character varying,
    ward integer,
    street_house_number character varying,
    street_prefix character varying,
    street_name character varying,
    street_suffix character varying,
    apartment_number character varying,
    dwelling_number character varying,
    family_id character varying,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    name_prefix character varying,
    name_suffix character varying,
    age integer,
    age_months integer,
    sex character varying,
    race character varying,
    occupation character varying DEFAULT 'None'::character varying,
    home_value integer,
    personal_value integer,
    pob character varying,
    just_married boolean,
    attended_school boolean,
    cannot_read_write boolean,
    deaf_dumb boolean,
    blind boolean,
    insane boolean,
    idiotic boolean,
    pauper boolean,
    convict boolean,
    nature_of_misfortune character varying,
    year_of_misfortune integer,
    notes text,
    foreign_born boolean DEFAULT false,
    taker_error boolean DEFAULT false,
    farm_schedule integer,
    searchable_name text,
    histid uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    sortable_name character varying
);


--
-- Name: census_1860_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_1860_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_1860_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_1860_records_id_seq OWNED BY public.census_1860_records.id;


--
-- Name: census_1870_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_1870_records (
    id bigint NOT NULL,
    locality_id bigint,
    building_id bigint,
    person_id bigint,
    created_by_id bigint,
    reviewed_by_id bigint,
    reviewed_at timestamp without time zone,
    page_number integer,
    page_side character varying(1),
    line_number integer,
    county character varying,
    city character varying,
    post_office character varying,
    state character varying,
    ward integer,
    street_house_number character varying,
    street_prefix character varying,
    street_name character varying,
    street_suffix character varying,
    apartment_number character varying,
    dwelling_number character varying,
    family_id character varying,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    name_prefix character varying,
    name_suffix character varying,
    age integer,
    age_months integer,
    sex character varying,
    race character varying,
    occupation character varying DEFAULT 'None'::character varying,
    home_value integer,
    personal_value integer,
    pob character varying,
    father_foreign_born boolean,
    mother_foreign_born boolean,
    attended_school boolean,
    cannot_read boolean,
    cannot_write boolean,
    deaf_dumb boolean,
    blind boolean,
    insane boolean,
    idiotic boolean,
    full_citizen boolean,
    denied_citizen boolean,
    notes text,
    foreign_born boolean DEFAULT false,
    taker_error boolean DEFAULT false,
    farm_schedule integer,
    searchable_name text,
    histid uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    birth_month integer,
    marriage_month integer,
    institution character varying,
    sortable_name character varying
);


--
-- Name: census_1870_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_1870_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_1870_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_1870_records_id_seq OWNED BY public.census_1870_records.id;


--
-- Name: census_1880_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_1880_records (
    id bigint NOT NULL,
    locality_id bigint,
    building_id bigint,
    person_id bigint,
    created_by_id bigint,
    reviewed_by_id bigint,
    reviewed_at timestamp without time zone,
    page_number integer,
    page_side character varying(1),
    line_number integer,
    county character varying,
    city character varying,
    state character varying,
    ward_str character varying,
    enum_dist_str character varying,
    street_house_number character varying,
    street_prefix character varying,
    street_name character varying,
    street_suffix character varying,
    apartment_number character varying,
    dwelling_number character varying,
    family_id character varying,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    name_prefix character varying,
    name_suffix character varying,
    sex character varying,
    race character varying,
    age integer,
    age_months integer,
    birth_month integer,
    relation_to_head character varying,
    marital_status character varying,
    just_married boolean,
    occupation character varying DEFAULT 'None'::character varying,
    unemployed_months integer,
    sick character varying,
    blind boolean,
    deaf_dumb boolean,
    idiotic boolean,
    insane boolean,
    maimed boolean,
    attended_school boolean,
    cannot_read boolean,
    cannot_write boolean,
    pob character varying,
    pob_father character varying,
    pob_mother character varying,
    notes text,
    provisional boolean DEFAULT false,
    foreign_born boolean DEFAULT false,
    taker_error boolean DEFAULT false,
    farm_schedule integer,
    searchable_name text,
    histid uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    enum_dist character varying NOT NULL,
    ward integer,
    institution character varying,
    sortable_name character varying
);


--
-- Name: census_1880_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_1880_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_1880_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_1880_records_id_seq OWNED BY public.census_1880_records.id;


--
-- Name: census_1900_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_1900_records (
    id integer NOT NULL,
    data jsonb,
    building_id integer,
    person_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    created_by_id integer,
    reviewed_by_id integer,
    reviewed_at timestamp without time zone,
    page_number integer,
    page_side character varying(1),
    line_number integer,
    county character varying,
    city character varying,
    state character varying,
    ward_str character varying,
    enum_dist_str character varying,
    street_prefix character varying,
    street_name character varying,
    street_suffix character varying,
    street_house_number character varying,
    dwelling_number character varying,
    family_id character varying,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    relation_to_head character varying,
    sex character varying,
    race character varying,
    birth_month integer,
    birth_year integer,
    age integer,
    marital_status character varying,
    years_married integer,
    num_children_born integer,
    num_children_alive integer,
    pob character varying,
    pob_father character varying,
    pob_mother character varying,
    year_immigrated integer,
    naturalized_alien character varying,
    years_in_us integer,
    occupation character varying DEFAULT 'None'::character varying,
    unemployed_months integer,
    attended_school_old boolean,
    can_read boolean,
    can_write boolean,
    can_speak_english boolean,
    owned_or_rented character varying,
    mortgage character varying,
    farm_or_house character varying,
    language_spoken character varying DEFAULT 'English'::character varying,
    notes text,
    provisional boolean DEFAULT false,
    foreign_born boolean DEFAULT false,
    taker_error boolean DEFAULT false,
    attended_school integer,
    industry character varying,
    farm_schedule integer,
    name_prefix character varying,
    name_suffix character varying,
    searchable_name text,
    apartment_number character varying,
    age_months integer,
    locality_id bigint,
    histid uuid,
    enum_dist character varying NOT NULL,
    ward integer,
    institution character varying,
    sortable_name character varying
);


--
-- Name: census_1900_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_1900_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_1900_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_1900_records_id_seq OWNED BY public.census_1900_records.id;


--
-- Name: census_1910_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_1910_records (
    id integer NOT NULL,
    data jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    building_id integer,
    created_by_id integer,
    reviewed_by_id integer,
    reviewed_at timestamp without time zone,
    person_id integer,
    page_number integer,
    page_side character varying(1),
    line_number integer,
    county character varying,
    city character varying,
    state character varying,
    ward_str character varying,
    enum_dist_str character varying,
    street_prefix character varying,
    street_name character varying,
    street_suffix character varying,
    street_house_number character varying,
    dwelling_number character varying,
    family_id character varying,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    relation_to_head character varying,
    sex character varying,
    race character varying,
    age integer,
    marital_status character varying,
    years_married integer,
    num_children_born integer,
    num_children_alive integer,
    pob character varying,
    pob_father character varying,
    pob_mother character varying,
    year_immigrated integer,
    naturalized_alien character varying,
    occupation character varying DEFAULT 'None'::character varying,
    industry character varying,
    employment character varying,
    unemployed boolean,
    attended_school boolean,
    can_read boolean,
    can_write boolean,
    can_speak_english boolean,
    owned_or_rented character varying,
    mortgage character varying,
    farm_or_house character varying,
    num_farm_sched character varying,
    language_spoken character varying DEFAULT 'English'::character varying,
    unemployed_weeks_1909 character varying,
    civil_war_vet_old boolean,
    blind boolean DEFAULT false,
    deaf_dumb boolean DEFAULT false,
    notes text,
    civil_war_vet character varying(2),
    provisional boolean DEFAULT false,
    foreign_born boolean DEFAULT false,
    taker_error boolean DEFAULT false,
    name_prefix character varying,
    name_suffix character varying,
    searchable_name text,
    apartment_number character varying,
    age_months integer,
    mother_tongue character varying,
    mother_tongue_father character varying,
    mother_tongue_mother character varying,
    locality_id bigint,
    histid uuid,
    enum_dist character varying NOT NULL,
    ward integer,
    institution character varying,
    sortable_name character varying
);


--
-- Name: census_1910_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_1910_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_1910_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_1910_records_id_seq OWNED BY public.census_1910_records.id;


--
-- Name: census_1920_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_1920_records (
    id integer NOT NULL,
    created_by_id integer,
    reviewed_by_id integer,
    reviewed_at timestamp without time zone,
    page_number integer,
    page_side character varying(1),
    line_number integer,
    county character varying,
    city character varying,
    state character varying,
    ward_str character varying,
    enum_dist_str character varying,
    street_prefix character varying,
    street_name character varying,
    street_suffix character varying,
    street_house_number character varying,
    dwelling_number character varying,
    family_id character varying,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    relation_to_head character varying,
    sex character varying,
    race character varying,
    age integer,
    marital_status character varying,
    year_immigrated integer,
    naturalized_alien character varying,
    pob character varying,
    mother_tongue character varying,
    pob_father character varying,
    mother_tongue_father character varying,
    pob_mother character varying,
    mother_tongue_mother character varying,
    can_speak_english boolean,
    occupation character varying DEFAULT 'None'::character varying,
    industry character varying,
    employment character varying,
    attended_school boolean,
    can_read boolean,
    can_write boolean,
    owned_or_rented character varying,
    mortgage character varying,
    farm_or_house character varying,
    notes text,
    provisional boolean DEFAULT false,
    foreign_born boolean DEFAULT false,
    taker_error boolean DEFAULT false,
    person_id integer,
    building_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name_prefix character varying,
    name_suffix character varying,
    year_naturalized integer,
    farm_schedule integer,
    searchable_name text,
    apartment_number character varying,
    age_months integer,
    employment_code character varying,
    locality_id bigint,
    histid uuid,
    enum_dist character varying NOT NULL,
    ward integer,
    institution character varying,
    sortable_name character varying
);


--
-- Name: census_1920_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_1920_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_1920_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_1920_records_id_seq OWNED BY public.census_1920_records.id;


--
-- Name: census_1930_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_1930_records (
    id integer NOT NULL,
    building_id integer,
    person_id integer,
    created_by_id integer,
    reviewed_by_id integer,
    reviewed_at timestamp without time zone,
    page_number integer,
    page_side character varying(1),
    line_number integer,
    county character varying,
    city character varying,
    state character varying,
    ward_str character varying,
    enum_dist_str character varying,
    street_prefix character varying,
    street_name character varying,
    street_suffix character varying,
    street_house_number character varying,
    dwelling_number character varying,
    family_id character varying,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    relation_to_head character varying,
    owned_or_rented character varying,
    home_value numeric,
    has_radio boolean,
    lives_on_farm boolean,
    sex character varying,
    race character varying,
    age integer,
    marital_status character varying,
    age_married integer,
    attended_school boolean,
    can_read_write boolean,
    pob character varying,
    pob_father character varying,
    pob_mother character varying,
    pob_code character varying,
    pob_father_code character varying,
    pob_mother_code character varying,
    mother_tongue character varying,
    year_immigrated integer,
    naturalized_alien character varying,
    can_speak_english boolean,
    occupation character varying DEFAULT 'None'::character varying,
    industry character varying,
    occupation_code character varying,
    worker_class character varying,
    worked_yesterday boolean,
    unemployment_line character varying,
    veteran boolean,
    war_fought character varying,
    farm_schedule character varying,
    notes text,
    provisional boolean DEFAULT false,
    foreign_born boolean DEFAULT false,
    taker_error boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name_prefix character varying,
    name_suffix character varying,
    searchable_name text,
    has_radio_int integer,
    lives_on_farm_int integer,
    attended_school_int integer,
    can_read_write_int integer,
    can_speak_english_int integer,
    worked_yesterday_int integer,
    veteran_int integer,
    foreign_born_int integer,
    homemaker_int integer,
    age_months integer,
    apartment_number character varying,
    homemaker boolean,
    industry1930_code_id bigint,
    occupation1930_code_id bigint,
    locality_id bigint,
    histid uuid,
    enum_dist character varying NOT NULL,
    ward integer,
    institution character varying,
    sortable_name character varying
);


--
-- Name: census_1930_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_1930_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_1930_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_1930_records_id_seq OWNED BY public.census_1930_records.id;


--
-- Name: census_1940_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_1940_records (
    id bigint NOT NULL,
    building_id bigint,
    person_id bigint,
    created_by_id bigint,
    reviewed_by_id bigint,
    reviewed_at timestamp without time zone,
    page_number integer,
    page_side character varying(1),
    line_number integer,
    county character varying,
    city character varying,
    state character varying,
    ward_str character varying,
    enum_dist_str character varying,
    apartment_number character varying,
    street_prefix character varying,
    street_name character varying,
    street_suffix character varying,
    street_house_number character varying,
    dwelling_number character varying,
    family_id character varying,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    name_prefix character varying,
    name_suffix character varying,
    searchable_name text,
    owned_or_rented character varying,
    home_value numeric,
    lives_on_farm boolean,
    relation_to_head character varying,
    sex character varying,
    race character varying,
    age integer,
    age_months integer,
    marital_status character varying,
    attended_school boolean,
    grade_completed character varying,
    pob character varying,
    naturalized_alien character varying,
    residence_1935_town character varying,
    residence_1935_county character varying,
    residence_1935_state character varying,
    residence_1935_farm boolean,
    private_work boolean,
    public_work boolean,
    seeking_work boolean,
    had_job boolean,
    no_work_reason character varying,
    private_hours_worked integer,
    unemployed_weeks integer,
    occupation character varying DEFAULT 'None'::character varying,
    industry character varying,
    worker_class character varying,
    occupation_code character varying,
    full_time_weeks integer,
    income integer,
    had_unearned_income boolean,
    farm_schedule character varying,
    pob_father character varying,
    pob_mother character varying,
    mother_tongue character varying,
    veteran boolean,
    veteran_dead boolean,
    war_fought character varying,
    soc_sec boolean,
    deductions boolean,
    deduction_rate character varying,
    usual_occupation character varying,
    usual_industry character varying,
    usual_worker_class character varying,
    usual_occupation_code character varying,
    usual_industry_code character varying,
    usual_worker_class_code character varying,
    multi_marriage boolean,
    first_marriage_age integer,
    children_born integer,
    notes text,
    provisional boolean DEFAULT false,
    foreign_born boolean DEFAULT false,
    taker_error boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    worker_class_code character varying,
    industry_code character varying,
    locality_id bigint,
    histid uuid,
    enum_dist character varying NOT NULL,
    ward integer,
    income_plus boolean,
    wages_or_salary character varying,
    institutional_work boolean,
    institution character varying,
    sortable_name character varying
);


--
-- Name: census_1940_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_1940_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_1940_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_1940_records_id_seq OWNED BY public.census_1940_records.id;


--
-- Name: census_1950_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.census_1950_records (
    id bigint NOT NULL,
    locality_id bigint,
    building_id bigint,
    person_id bigint,
    created_by_id bigint,
    reviewed_by_id bigint,
    reviewed_at timestamp(6) without time zone,
    page_number integer,
    page_side character varying(1),
    line_number integer,
    county character varying,
    city character varying,
    state character varying,
    ward integer,
    enum_dist character varying NOT NULL,
    institution_name character varying,
    institution_type character varying,
    apartment_number character varying,
    street_prefix character varying,
    street_name character varying,
    street_suffix character varying,
    street_house_number character varying,
    dwelling_number character varying,
    family_id character varying,
    lives_on_farm boolean,
    lives_on_3_acres boolean,
    ag_questionnaire_no character varying,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    name_prefix character varying,
    name_suffix character varying,
    searchable_name text,
    relation_to_head character varying,
    race character varying,
    sex character varying,
    age integer,
    marital_status character varying,
    pob character varying,
    foreign_born boolean DEFAULT false,
    naturalized_alien character varying,
    activity_last_week character varying,
    worked_last_week boolean,
    seeking_work boolean,
    employed_absent boolean,
    hours_worked integer,
    occupation character varying DEFAULT 'None'::character varying,
    industry character varying,
    worker_class character varying,
    occupation_code character varying,
    industry_code character varying,
    worker_class_code character varying,
    same_house_1949 boolean,
    on_farm_1949 boolean,
    same_county_1949 boolean,
    county_1949 character varying,
    state_1949 character varying,
    pob_father character varying,
    pob_mother character varying,
    highest_grade character varying,
    finished_grade boolean,
    weeks_seeking_work integer,
    weeks_worked integer,
    wages_or_salary_self character varying,
    own_business_self character varying,
    unearned_income_self character varying,
    wages_or_salary_family character varying,
    own_business_family character varying,
    unearned_income_family character varying,
    veteran_ww2 boolean,
    veteran_ww1 boolean,
    veteran_other boolean,
    item_20_entries boolean,
    last_occupation character varying,
    last_industry character varying,
    last_worker_class character varying,
    multi_marriage boolean,
    years_married integer,
    newlyweds boolean,
    children_born integer,
    notes text,
    provisional boolean DEFAULT false,
    taker_error boolean DEFAULT false,
    histid uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    birth_month integer,
    attended_school boolean DEFAULT false,
    sortable_name character varying
);


--
-- Name: census_1950_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.census_1950_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: census_1950_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.census_1950_records_id_seq OWNED BY public.census_1950_records.id;


--
-- Name: client_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_applications (
    id integer NOT NULL,
    name character varying,
    url character varying,
    support_url character varying,
    callback_url character varying,
    key character varying(20),
    secret character varying(40),
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: client_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_applications_id_seq OWNED BY public.client_applications.id;


--
-- Name: cms_page_widgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cms_page_widgets (
    id bigint NOT NULL,
    cms_page_id bigint,
    type character varying,
    data jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cms_page_widgets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cms_page_widgets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cms_page_widgets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cms_page_widgets_id_seq OWNED BY public.cms_page_widgets.id;


--
-- Name: cms_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cms_pages (
    id bigint NOT NULL,
    type character varying DEFAULT 'Cms::Page'::character varying,
    url_path character varying,
    controller character varying,
    action character varying,
    published boolean DEFAULT true,
    visible boolean DEFAULT false,
    data json,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cms_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cms_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cms_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cms_pages_id_seq OWNED BY public.cms_pages.id;


--
-- Name: construction_materials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.construction_materials (
    id integer NOT NULL,
    name character varying,
    color character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: construction_materials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.construction_materials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: construction_materials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.construction_materials_id_seq OWNED BY public.construction_materials.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    data jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: document_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_categories (
    id bigint NOT NULL,
    name character varying,
    description text,
    "position" integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: document_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.document_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: document_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.document_categories_id_seq OWNED BY public.document_categories.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id bigint NOT NULL,
    document_category_id bigint,
    file character varying,
    name character varying,
    description text,
    "position" integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    url character varying,
    available_to_public boolean DEFAULT false
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: documents_localities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents_localities (
    document_id bigint,
    locality_id bigint
);


--
-- Name: flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flags (
    id bigint NOT NULL,
    flaggable_type character varying,
    flaggable_id bigint,
    user_id bigint,
    reason character varying,
    message text,
    comment text,
    resolved_by_id bigint,
    resolved_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.flags_id_seq OWNED BY public.flags.id;


--
-- Name: imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.imports (
    id integer NOT NULL,
    path character varying,
    name character varying,
    layer_title character varying,
    map_title_suffix character varying,
    map_description character varying,
    map_publisher character varying,
    map_author character varying,
    state character varying,
    layer_id integer,
    uploader_user_id integer,
    user_id integer,
    file_count integer,
    imported_count integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.imports_id_seq OWNED BY public.imports.id;


--
-- Name: industry1930_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.industry1930_codes (
    id bigint NOT NULL,
    code character varying,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: industry1930_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.industry1930_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: industry1930_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.industry1930_codes_id_seq OWNED BY public.industry1930_codes.id;


--
-- Name: ipums_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ipums_records (
    histid uuid NOT NULL,
    serial integer,
    year integer,
    data jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: localities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.localities (
    id bigint NOT NULL,
    name character varying,
    latitude numeric,
    longitude numeric,
    "position" integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    year_street_renumber integer,
    slug character varying,
    short_name character varying,
    "primary" boolean DEFAULT false NOT NULL
);


--
-- Name: localities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.localities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: localities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.localities_id_seq OWNED BY public.localities.id;


--
-- Name: localities_map_overlays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.localities_map_overlays (
    locality_id bigint NOT NULL,
    map_overlay_id bigint NOT NULL
);


--
-- Name: localities_people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.localities_people (
    locality_id bigint,
    person_id bigint
);


--
-- Name: map_overlays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.map_overlays (
    id bigint NOT NULL,
    name character varying,
    year_depicted integer,
    url character varying,
    active boolean,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    locality_id bigint,
    layers_param character varying
);


--
-- Name: map_overlays_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.map_overlays_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: map_overlays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.map_overlays_id_seq OWNED BY public.map_overlays.id;


--
-- Name: narratives; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.narratives (
    id bigint NOT NULL,
    created_by_id bigint NOT NULL,
    reviewed_by_id bigint,
    reviewed_at timestamp(6) without time zone,
    weight integer DEFAULT 0,
    source character varying,
    notes text,
    date_type integer,
    date_text character varying,
    date_start date,
    date_end date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: narratives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.narratives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: narratives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.narratives_id_seq OWNED BY public.narratives.id;


--
-- Name: narratives_people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.narratives_people (
    narrative_id bigint,
    person_id bigint
);


--
-- Name: occupation1930_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.occupation1930_codes (
    id bigint NOT NULL,
    code character varying,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: occupation1930_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.occupation1930_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: occupation1930_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.occupation1930_codes_id_seq OWNED BY public.occupation1930_codes.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.people (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    sex character varying(12),
    race character varying,
    name_prefix character varying,
    name_suffix character varying,
    searchable_name text,
    birth_year integer,
    is_birth_year_estimated boolean DEFAULT true,
    pob character varying,
    is_pob_estimated boolean DEFAULT true,
    notes text,
    description text,
    sortable_name character varying
);


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.people_id_seq OWNED BY public.people.id;


--
-- Name: people_photographs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.people_photographs (
    photograph_id bigint NOT NULL,
    person_id bigint NOT NULL
);


--
-- Name: people_videos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.people_videos (
    person_id bigint,
    video_id bigint
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    role_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: person_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person_names (
    id bigint NOT NULL,
    person_id bigint NOT NULL,
    is_primary boolean,
    last_name character varying,
    first_name character varying,
    middle_name character varying,
    name_prefix character varying,
    name_suffix character varying,
    searchable_name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    sortable_name character varying
);


--
-- Name: person_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.person_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: person_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.person_names_id_seq OWNED BY public.person_names.id;


--
-- Name: pg_search_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pg_search_documents (
    id bigint NOT NULL,
    content text,
    searchable_type character varying,
    searchable_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pg_search_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pg_search_documents_id_seq OWNED BY public.pg_search_documents.id;


--
-- Name: photographs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.photographs (
    id bigint NOT NULL,
    created_by_id bigint,
    building_id bigint,
    description text,
    creator character varying,
    date_text character varying,
    date_start date,
    date_end date,
    location character varying,
    identifier character varying,
    notes text,
    latitude numeric,
    longitude numeric,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    reviewed_by_id bigint,
    reviewed_at timestamp without time zone,
    date_type integer DEFAULT 0,
    caption text
);


--
-- Name: photographs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.photographs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: photographs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.photographs_id_seq OWNED BY public.photographs.id;


--
-- Name: profession_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profession_groups (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: profession_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.profession_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profession_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.profession_groups_id_seq OWNED BY public.profession_groups.id;


--
-- Name: profession_subgroups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profession_subgroups (
    id bigint NOT NULL,
    name character varying,
    profession_group_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: profession_subgroups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.profession_subgroups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profession_subgroups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.profession_subgroups_id_seq OWNED BY public.profession_subgroups.id;


--
-- Name: professions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.professions (
    id bigint NOT NULL,
    code character varying,
    name character varying,
    profession_group_id bigint,
    profession_subgroup_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: professions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.professions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: professions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.professions_id_seq OWNED BY public.professions.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying,
    updated_by integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: search_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.search_params (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    model character varying,
    params jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: search_params_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.search_params_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: search_params_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.search_params_id_seq OWNED BY public.search_params.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    id bigint NOT NULL,
    key character varying,
    name character varying,
    hint character varying,
    input_type character varying,
    "group" character varying,
    value text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    settings_group_id bigint
);


--
-- Name: settings_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings_groups (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: settings_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settings_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settings_groups_id_seq OWNED BY public.settings_groups.id;


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: street_conversions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.street_conversions (
    id bigint NOT NULL,
    from_prefix character varying,
    to_prefix character varying,
    from_name character varying,
    to_name character varying,
    from_suffix character varying,
    to_suffix character varying,
    from_city character varying,
    to_city character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    from_house_number character varying,
    to_house_number character varying,
    year integer
);


--
-- Name: street_conversions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.street_conversions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: street_conversions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.street_conversions_id_seq OWNED BY public.street_conversions.id;


--
-- Name: terms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.terms (
    id bigint NOT NULL,
    vocabulary_id bigint,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    ipums integer
);


--
-- Name: terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.terms_id_seq OWNED BY public.terms.id;


--
-- Name: user_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_groups (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_groups_id_seq OWNED BY public.user_groups.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    login character varying,
    email character varying,
    encrypted_password character varying(128) DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    remember_token character varying,
    remember_token_expires_at timestamp without time zone,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    reset_password_token character varying,
    enabled boolean DEFAULT true,
    updated_by integer,
    description text DEFAULT ''::text,
    confirmation_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    reset_password_sent_at timestamp without time zone,
    provider character varying,
    uid character varying,
    invitation_token character varying,
    invitation_created_at timestamp without time zone,
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_type character varying,
    invited_by_id bigint,
    invitations_count integer DEFAULT 0,
    roles_mask integer,
    user_group_id bigint,
    unconfirmed_email character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_id bigint NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp without time zone,
    object_changes text,
    comment character varying
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: videos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.videos (
    id bigint NOT NULL,
    created_by_id bigint NOT NULL,
    reviewed_by_id bigint,
    reviewed_at timestamp(6) without time zone,
    description text,
    notes text,
    caption text,
    creator character varying,
    date_type integer,
    date_text character varying,
    date_start date,
    date_end date,
    location character varying,
    identifier character varying,
    latitude numeric,
    longitude numeric,
    duration integer,
    file_size integer,
    width integer,
    height integer,
    thumbnail_processed_at timestamp(6) without time zone,
    processed_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    remote_url character varying
);


--
-- Name: videos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.videos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.videos_id_seq OWNED BY public.videos.id;


--
-- Name: vocabularies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabularies (
    id bigint NOT NULL,
    name character varying,
    machine_name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: vocabularies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabularies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabularies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabularies_id_seq OWNED BY public.vocabularies.id;


--
-- Name: action_text_rich_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts ALTER COLUMN id SET DEFAULT nextval('public.action_text_rich_texts_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- Name: annotations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.annotations ALTER COLUMN id SET DEFAULT nextval('public.annotations_id_seq'::regclass);


--
-- Name: architects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.architects ALTER COLUMN id SET DEFAULT nextval('public.architects_id_seq'::regclass);


--
-- Name: audios id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audios ALTER COLUMN id SET DEFAULT nextval('public.audios_id_seq'::regclass);


--
-- Name: audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);


--
-- Name: building_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_types ALTER COLUMN id SET DEFAULT nextval('public.building_types_id_seq'::regclass);


--
-- Name: buildings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings ALTER COLUMN id SET DEFAULT nextval('public.buildings_id_seq'::regclass);


--
-- Name: bulk_updated_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_updated_records ALTER COLUMN id SET DEFAULT nextval('public.bulk_updated_records_id_seq'::regclass);


--
-- Name: bulk_updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_updates ALTER COLUMN id SET DEFAULT nextval('public.bulk_updates_id_seq'::regclass);


--
-- Name: census_1850_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1850_records ALTER COLUMN id SET DEFAULT nextval('public.census_1850_records_id_seq'::regclass);


--
-- Name: census_1860_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1860_records ALTER COLUMN id SET DEFAULT nextval('public.census_1860_records_id_seq'::regclass);


--
-- Name: census_1870_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1870_records ALTER COLUMN id SET DEFAULT nextval('public.census_1870_records_id_seq'::regclass);


--
-- Name: census_1880_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1880_records ALTER COLUMN id SET DEFAULT nextval('public.census_1880_records_id_seq'::regclass);


--
-- Name: census_1900_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1900_records ALTER COLUMN id SET DEFAULT nextval('public.census_1900_records_id_seq'::regclass);


--
-- Name: census_1910_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1910_records ALTER COLUMN id SET DEFAULT nextval('public.census_1910_records_id_seq'::regclass);


--
-- Name: census_1920_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1920_records ALTER COLUMN id SET DEFAULT nextval('public.census_1920_records_id_seq'::regclass);


--
-- Name: census_1930_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1930_records ALTER COLUMN id SET DEFAULT nextval('public.census_1930_records_id_seq'::regclass);


--
-- Name: census_1940_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1940_records ALTER COLUMN id SET DEFAULT nextval('public.census_1940_records_id_seq'::regclass);


--
-- Name: census_1950_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1950_records ALTER COLUMN id SET DEFAULT nextval('public.census_1950_records_id_seq'::regclass);


--
-- Name: client_applications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_applications ALTER COLUMN id SET DEFAULT nextval('public.client_applications_id_seq'::regclass);


--
-- Name: cms_page_widgets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_page_widgets ALTER COLUMN id SET DEFAULT nextval('public.cms_page_widgets_id_seq'::regclass);


--
-- Name: cms_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_pages ALTER COLUMN id SET DEFAULT nextval('public.cms_pages_id_seq'::regclass);


--
-- Name: construction_materials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.construction_materials ALTER COLUMN id SET DEFAULT nextval('public.construction_materials_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: document_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_categories ALTER COLUMN id SET DEFAULT nextval('public.document_categories_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags ALTER COLUMN id SET DEFAULT nextval('public.flags_id_seq'::regclass);


--
-- Name: imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports ALTER COLUMN id SET DEFAULT nextval('public.imports_id_seq'::regclass);


--
-- Name: industry1930_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.industry1930_codes ALTER COLUMN id SET DEFAULT nextval('public.industry1930_codes_id_seq'::regclass);


--
-- Name: localities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localities ALTER COLUMN id SET DEFAULT nextval('public.localities_id_seq'::regclass);


--
-- Name: map_overlays id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.map_overlays ALTER COLUMN id SET DEFAULT nextval('public.map_overlays_id_seq'::regclass);


--
-- Name: narratives id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.narratives ALTER COLUMN id SET DEFAULT nextval('public.narratives_id_seq'::regclass);


--
-- Name: occupation1930_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.occupation1930_codes ALTER COLUMN id SET DEFAULT nextval('public.occupation1930_codes_id_seq'::regclass);


--
-- Name: people id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people ALTER COLUMN id SET DEFAULT nextval('public.people_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: person_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_names ALTER COLUMN id SET DEFAULT nextval('public.person_names_id_seq'::regclass);


--
-- Name: pg_search_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pg_search_documents ALTER COLUMN id SET DEFAULT nextval('public.pg_search_documents_id_seq'::regclass);


--
-- Name: photographs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photographs ALTER COLUMN id SET DEFAULT nextval('public.photographs_id_seq'::regclass);


--
-- Name: profession_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profession_groups ALTER COLUMN id SET DEFAULT nextval('public.profession_groups_id_seq'::regclass);


--
-- Name: profession_subgroups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profession_subgroups ALTER COLUMN id SET DEFAULT nextval('public.profession_subgroups_id_seq'::regclass);


--
-- Name: professions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professions ALTER COLUMN id SET DEFAULT nextval('public.professions_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: search_params id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_params ALTER COLUMN id SET DEFAULT nextval('public.search_params_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: settings_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings_groups ALTER COLUMN id SET DEFAULT nextval('public.settings_groups_id_seq'::regclass);


--
-- Name: street_conversions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.street_conversions ALTER COLUMN id SET DEFAULT nextval('public.street_conversions_id_seq'::regclass);


--
-- Name: terms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.terms ALTER COLUMN id SET DEFAULT nextval('public.terms_id_seq'::regclass);


--
-- Name: user_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups ALTER COLUMN id SET DEFAULT nextval('public.user_groups_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Name: videos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.videos ALTER COLUMN id SET DEFAULT nextval('public.videos_id_seq'::regclass);


--
-- Name: vocabularies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabularies ALTER COLUMN id SET DEFAULT nextval('public.vocabularies_id_seq'::regclass);


--
-- Name: action_text_rich_texts action_text_rich_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts
    ADD CONSTRAINT action_text_rich_texts_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: annotations annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.annotations
    ADD CONSTRAINT annotations_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: architects architects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.architects
    ADD CONSTRAINT architects_pkey PRIMARY KEY (id);


--
-- Name: audios audios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audios
    ADD CONSTRAINT audios_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: building_types building_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_types
    ADD CONSTRAINT building_types_pkey PRIMARY KEY (id);


--
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- Name: bulk_updated_records bulk_updated_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_updated_records
    ADD CONSTRAINT bulk_updated_records_pkey PRIMARY KEY (id);


--
-- Name: bulk_updates bulk_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_updates
    ADD CONSTRAINT bulk_updates_pkey PRIMARY KEY (id);


--
-- Name: census_1850_records census_1850_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1850_records
    ADD CONSTRAINT census_1850_records_pkey PRIMARY KEY (id);


--
-- Name: census_1860_records census_1860_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1860_records
    ADD CONSTRAINT census_1860_records_pkey PRIMARY KEY (id);


--
-- Name: census_1870_records census_1870_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1870_records
    ADD CONSTRAINT census_1870_records_pkey PRIMARY KEY (id);


--
-- Name: census_1880_records census_1880_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1880_records
    ADD CONSTRAINT census_1880_records_pkey PRIMARY KEY (id);


--
-- Name: census_1900_records census_1900_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1900_records
    ADD CONSTRAINT census_1900_records_pkey PRIMARY KEY (id);


--
-- Name: census_1910_records census_1910_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1910_records
    ADD CONSTRAINT census_1910_records_pkey PRIMARY KEY (id);


--
-- Name: census_1920_records census_1920_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1920_records
    ADD CONSTRAINT census_1920_records_pkey PRIMARY KEY (id);


--
-- Name: census_1930_records census_1930_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1930_records
    ADD CONSTRAINT census_1930_records_pkey PRIMARY KEY (id);


--
-- Name: census_1940_records census_1940_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1940_records
    ADD CONSTRAINT census_1940_records_pkey PRIMARY KEY (id);


--
-- Name: census_1950_records census_1950_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1950_records
    ADD CONSTRAINT census_1950_records_pkey PRIMARY KEY (id);


--
-- Name: client_applications client_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_applications
    ADD CONSTRAINT client_applications_pkey PRIMARY KEY (id);


--
-- Name: cms_page_widgets cms_page_widgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_page_widgets
    ADD CONSTRAINT cms_page_widgets_pkey PRIMARY KEY (id);


--
-- Name: cms_pages cms_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_pages
    ADD CONSTRAINT cms_pages_pkey PRIMARY KEY (id);


--
-- Name: construction_materials construction_materials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.construction_materials
    ADD CONSTRAINT construction_materials_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: document_categories document_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_categories
    ADD CONSTRAINT document_categories_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: flags flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT flags_pkey PRIMARY KEY (id);


--
-- Name: imports imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT imports_pkey PRIMARY KEY (id);


--
-- Name: industry1930_codes industry1930_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.industry1930_codes
    ADD CONSTRAINT industry1930_codes_pkey PRIMARY KEY (id);


--
-- Name: ipums_records ipums_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ipums_records
    ADD CONSTRAINT ipums_records_pkey PRIMARY KEY (histid);


--
-- Name: localities localities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localities
    ADD CONSTRAINT localities_pkey PRIMARY KEY (id);


--
-- Name: map_overlays map_overlays_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.map_overlays
    ADD CONSTRAINT map_overlays_pkey PRIMARY KEY (id);


--
-- Name: narratives narratives_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.narratives
    ADD CONSTRAINT narratives_pkey PRIMARY KEY (id);


--
-- Name: occupation1930_codes occupation1930_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.occupation1930_codes
    ADD CONSTRAINT occupation1930_codes_pkey PRIMARY KEY (id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: person_names person_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_names
    ADD CONSTRAINT person_names_pkey PRIMARY KEY (id);


--
-- Name: pg_search_documents pg_search_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pg_search_documents
    ADD CONSTRAINT pg_search_documents_pkey PRIMARY KEY (id);


--
-- Name: photographs photographs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photographs
    ADD CONSTRAINT photographs_pkey PRIMARY KEY (id);


--
-- Name: profession_groups profession_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profession_groups
    ADD CONSTRAINT profession_groups_pkey PRIMARY KEY (id);


--
-- Name: profession_subgroups profession_subgroups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profession_subgroups
    ADD CONSTRAINT profession_subgroups_pkey PRIMARY KEY (id);


--
-- Name: professions professions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professions
    ADD CONSTRAINT professions_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: search_params search_params_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_params
    ADD CONSTRAINT search_params_pkey PRIMARY KEY (id);


--
-- Name: settings_groups settings_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings_groups
    ADD CONSTRAINT settings_groups_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: street_conversions street_conversions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.street_conversions
    ADD CONSTRAINT street_conversions_pkey PRIMARY KEY (id);


--
-- Name: terms terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.terms
    ADD CONSTRAINT terms_pkey PRIMARY KEY (id);


--
-- Name: user_groups user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_groups
    ADD CONSTRAINT user_groups_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: videos videos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);


--
-- Name: vocabularies vocabularies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabularies
    ADD CONSTRAINT vocabularies_pkey PRIMARY KEY (id);


--
-- Name: architects_buildings_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX architects_buildings_index ON public.architects_buildings USING btree (architect_id, building_id);


--
-- Name: buildings_building_types_unique_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX buildings_building_types_unique_index ON public.buildings_building_types USING btree (building_id, building_type_id);


--
-- Name: index_action_text_rich_texts_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_action_text_rich_texts_uniqueness ON public.action_text_rich_texts USING btree (record_type, record_id, name);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_addresses_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_building_id ON public.addresses USING btree (building_id);


--
-- Name: index_annotations_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_annotations_on_building_id ON public.annotations USING btree (building_id);


--
-- Name: index_annotations_on_building_id_and_map_overlay_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_annotations_on_building_id_and_map_overlay_id ON public.annotations USING btree (building_id, map_overlay_id);


--
-- Name: index_annotations_on_map_overlay_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_annotations_on_map_overlay_id ON public.annotations USING btree (map_overlay_id);


--
-- Name: index_audios_buildings_on_audio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audios_buildings_on_audio_id ON public.audios_buildings USING btree (audio_id);


--
-- Name: index_audios_buildings_on_audio_id_and_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audios_buildings_on_audio_id_and_building_id ON public.audios_buildings USING btree (audio_id, building_id);


--
-- Name: index_audios_buildings_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audios_buildings_on_building_id ON public.audios_buildings USING btree (building_id);


--
-- Name: index_audios_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audios_on_created_by_id ON public.audios USING btree (created_by_id);


--
-- Name: index_audios_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audios_on_reviewed_by_id ON public.audios USING btree (reviewed_by_id);


--
-- Name: index_audios_people_on_audio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audios_people_on_audio_id ON public.audios_people USING btree (audio_id);


--
-- Name: index_audios_people_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audios_people_on_person_id ON public.audios_people USING btree (person_id);


--
-- Name: index_audios_people_on_person_id_and_audio_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audios_people_on_person_id_and_audio_id ON public.audios_people USING btree (person_id, audio_id);


--
-- Name: index_audit_logs_on_loggable_type_and_loggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audit_logs_on_loggable_type_and_loggable_id ON public.audit_logs USING btree (loggable_type, loggable_id);


--
-- Name: index_audit_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audit_logs_on_user_id ON public.audit_logs USING btree (user_id);


--
-- Name: index_buildings_building_types_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_building_types_on_building_id ON public.buildings_building_types USING btree (building_id);


--
-- Name: index_buildings_building_types_on_building_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_building_types_on_building_type_id ON public.buildings_building_types USING btree (building_type_id);


--
-- Name: index_buildings_narratives_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_narratives_on_building_id ON public.buildings_narratives USING btree (building_id);


--
-- Name: index_buildings_narratives_on_building_id_and_narrative_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_buildings_narratives_on_building_id_and_narrative_id ON public.buildings_narratives USING btree (building_id, narrative_id);


--
-- Name: index_buildings_narratives_on_narrative_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_narratives_on_narrative_id ON public.buildings_narratives USING btree (narrative_id);


--
-- Name: index_buildings_on_building_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_building_type_id ON public.buildings USING btree (building_type_id);


--
-- Name: index_buildings_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_created_by_id ON public.buildings USING btree (created_by_id);


--
-- Name: index_buildings_on_frame_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_frame_type_id ON public.buildings USING btree (frame_type_id);


--
-- Name: index_buildings_on_lining_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_lining_type_id ON public.buildings USING btree (lining_type_id);


--
-- Name: index_buildings_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_locality_id ON public.buildings USING btree (locality_id);


--
-- Name: index_buildings_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_parent_id ON public.buildings USING btree (parent_id);


--
-- Name: index_buildings_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_reviewed_by_id ON public.buildings USING btree (reviewed_by_id);


--
-- Name: index_buildings_videos_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_videos_on_building_id ON public.buildings_videos USING btree (building_id);


--
-- Name: index_buildings_videos_on_building_id_and_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_videos_on_building_id_and_video_id ON public.buildings_videos USING btree (building_id, video_id);


--
-- Name: index_buildings_videos_on_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_videos_on_video_id ON public.buildings_videos USING btree (video_id);


--
-- Name: index_bulk_updated_records_on_bulk_update_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bulk_updated_records_on_bulk_update_id ON public.bulk_updated_records USING btree (bulk_update_id);


--
-- Name: index_bulk_updated_records_on_record_type_and_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bulk_updated_records_on_record_type_and_record_id ON public.bulk_updated_records USING btree (record_type, record_id);


--
-- Name: index_bulk_updates_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bulk_updates_on_user_id ON public.bulk_updates USING btree (user_id);


--
-- Name: index_census_1850_records_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1850_records_on_building_id ON public.census_1850_records USING btree (building_id);


--
-- Name: index_census_1850_records_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1850_records_on_created_by_id ON public.census_1850_records USING btree (created_by_id);


--
-- Name: index_census_1850_records_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1850_records_on_locality_id ON public.census_1850_records USING btree (locality_id);


--
-- Name: index_census_1850_records_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1850_records_on_person_id ON public.census_1850_records USING btree (person_id);


--
-- Name: index_census_1850_records_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1850_records_on_reviewed_by_id ON public.census_1850_records USING btree (reviewed_by_id);


--
-- Name: index_census_1850_records_on_searchable_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1850_records_on_searchable_name ON public.census_1850_records USING gin (searchable_name public.gin_trgm_ops);


--
-- Name: index_census_1860_records_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1860_records_on_building_id ON public.census_1860_records USING btree (building_id);


--
-- Name: index_census_1860_records_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1860_records_on_created_by_id ON public.census_1860_records USING btree (created_by_id);


--
-- Name: index_census_1860_records_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1860_records_on_locality_id ON public.census_1860_records USING btree (locality_id);


--
-- Name: index_census_1860_records_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1860_records_on_person_id ON public.census_1860_records USING btree (person_id);


--
-- Name: index_census_1860_records_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1860_records_on_reviewed_by_id ON public.census_1860_records USING btree (reviewed_by_id);


--
-- Name: index_census_1860_records_on_searchable_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1860_records_on_searchable_name ON public.census_1860_records USING gin (searchable_name public.gin_trgm_ops);


--
-- Name: index_census_1870_records_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1870_records_on_building_id ON public.census_1870_records USING btree (building_id);


--
-- Name: index_census_1870_records_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1870_records_on_created_by_id ON public.census_1870_records USING btree (created_by_id);


--
-- Name: index_census_1870_records_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1870_records_on_locality_id ON public.census_1870_records USING btree (locality_id);


--
-- Name: index_census_1870_records_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1870_records_on_person_id ON public.census_1870_records USING btree (person_id);


--
-- Name: index_census_1870_records_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1870_records_on_reviewed_by_id ON public.census_1870_records USING btree (reviewed_by_id);


--
-- Name: index_census_1870_records_on_searchable_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1870_records_on_searchable_name ON public.census_1870_records USING gin (searchable_name public.gin_trgm_ops);


--
-- Name: index_census_1880_records_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1880_records_on_building_id ON public.census_1880_records USING btree (building_id);


--
-- Name: index_census_1880_records_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1880_records_on_created_by_id ON public.census_1880_records USING btree (created_by_id);


--
-- Name: index_census_1880_records_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1880_records_on_locality_id ON public.census_1880_records USING btree (locality_id);


--
-- Name: index_census_1880_records_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1880_records_on_person_id ON public.census_1880_records USING btree (person_id);


--
-- Name: index_census_1880_records_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1880_records_on_reviewed_by_id ON public.census_1880_records USING btree (reviewed_by_id);


--
-- Name: index_census_1880_records_on_searchable_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1880_records_on_searchable_name ON public.census_1880_records USING gin (searchable_name public.gin_trgm_ops);


--
-- Name: index_census_1900_records_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1900_records_on_building_id ON public.census_1900_records USING btree (building_id);


--
-- Name: index_census_1900_records_on_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1900_records_on_data ON public.census_1900_records USING gin (data);


--
-- Name: index_census_1900_records_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1900_records_on_locality_id ON public.census_1900_records USING btree (locality_id);


--
-- Name: index_census_1900_records_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1900_records_on_person_id ON public.census_1900_records USING btree (person_id);


--
-- Name: index_census_1900_records_on_searchable_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1900_records_on_searchable_name ON public.census_1900_records USING gin (searchable_name public.gin_trgm_ops);


--
-- Name: index_census_1910_records_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1910_records_on_building_id ON public.census_1910_records USING btree (building_id);


--
-- Name: index_census_1910_records_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1910_records_on_created_by_id ON public.census_1910_records USING btree (created_by_id);


--
-- Name: index_census_1910_records_on_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1910_records_on_data ON public.census_1910_records USING gin (data);


--
-- Name: index_census_1910_records_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1910_records_on_locality_id ON public.census_1910_records USING btree (locality_id);


--
-- Name: index_census_1910_records_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1910_records_on_person_id ON public.census_1910_records USING btree (person_id);


--
-- Name: index_census_1910_records_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1910_records_on_reviewed_by_id ON public.census_1910_records USING btree (reviewed_by_id);


--
-- Name: index_census_1910_records_on_searchable_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1910_records_on_searchable_name ON public.census_1910_records USING gin (searchable_name public.gin_trgm_ops);


--
-- Name: index_census_1920_records_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1920_records_on_building_id ON public.census_1920_records USING btree (building_id);


--
-- Name: index_census_1920_records_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1920_records_on_locality_id ON public.census_1920_records USING btree (locality_id);


--
-- Name: index_census_1920_records_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1920_records_on_person_id ON public.census_1920_records USING btree (person_id);


--
-- Name: index_census_1920_records_on_searchable_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1920_records_on_searchable_name ON public.census_1920_records USING gin (searchable_name public.gin_trgm_ops);


--
-- Name: index_census_1930_records_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1930_records_on_building_id ON public.census_1930_records USING btree (building_id);


--
-- Name: index_census_1930_records_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1930_records_on_created_by_id ON public.census_1930_records USING btree (created_by_id);


--
-- Name: index_census_1930_records_on_industry1930_code_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1930_records_on_industry1930_code_id ON public.census_1930_records USING btree (industry1930_code_id);


--
-- Name: index_census_1930_records_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1930_records_on_locality_id ON public.census_1930_records USING btree (locality_id);


--
-- Name: index_census_1930_records_on_occupation1930_code_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1930_records_on_occupation1930_code_id ON public.census_1930_records USING btree (occupation1930_code_id);


--
-- Name: index_census_1930_records_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1930_records_on_person_id ON public.census_1930_records USING btree (person_id);


--
-- Name: index_census_1930_records_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1930_records_on_reviewed_by_id ON public.census_1930_records USING btree (reviewed_by_id);


--
-- Name: index_census_1930_records_on_searchable_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1930_records_on_searchable_name ON public.census_1930_records USING gin (searchable_name public.gin_trgm_ops);


--
-- Name: index_census_1940_records_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1940_records_on_building_id ON public.census_1940_records USING btree (building_id);


--
-- Name: index_census_1940_records_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1940_records_on_created_by_id ON public.census_1940_records USING btree (created_by_id);


--
-- Name: index_census_1940_records_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1940_records_on_locality_id ON public.census_1940_records USING btree (locality_id);


--
-- Name: index_census_1940_records_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1940_records_on_person_id ON public.census_1940_records USING btree (person_id);


--
-- Name: index_census_1940_records_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1940_records_on_reviewed_by_id ON public.census_1940_records USING btree (reviewed_by_id);


--
-- Name: index_census_1940_records_on_searchable_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1940_records_on_searchable_name ON public.census_1940_records USING gin (searchable_name public.gin_trgm_ops);


--
-- Name: index_census_1950_records_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1950_records_on_building_id ON public.census_1950_records USING btree (building_id);


--
-- Name: index_census_1950_records_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1950_records_on_created_by_id ON public.census_1950_records USING btree (created_by_id);


--
-- Name: index_census_1950_records_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1950_records_on_locality_id ON public.census_1950_records USING btree (locality_id);


--
-- Name: index_census_1950_records_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1950_records_on_person_id ON public.census_1950_records USING btree (person_id);


--
-- Name: index_census_1950_records_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1950_records_on_reviewed_by_id ON public.census_1950_records USING btree (reviewed_by_id);


--
-- Name: index_census_1950_records_on_searchable_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_census_1950_records_on_searchable_name ON public.census_1950_records USING gin (searchable_name public.gin_trgm_ops);


--
-- Name: index_client_applications_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_client_applications_on_key ON public.client_applications USING btree (key);


--
-- Name: index_cms_page_widgets_on_cms_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cms_page_widgets_on_cms_page_id ON public.cms_page_widgets USING btree (cms_page_id);


--
-- Name: index_cms_pages_on_controller_and_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cms_pages_on_controller_and_action ON public.cms_pages USING btree (controller, action);


--
-- Name: index_cms_pages_on_url_path; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cms_pages_on_url_path ON public.cms_pages USING btree (url_path);


--
-- Name: index_documents_localities_on_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_localities_on_document_id ON public.documents_localities USING btree (document_id);


--
-- Name: index_documents_localities_on_document_id_and_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_documents_localities_on_document_id_and_locality_id ON public.documents_localities USING btree (document_id, locality_id);


--
-- Name: index_documents_localities_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_localities_on_locality_id ON public.documents_localities USING btree (locality_id);


--
-- Name: index_documents_on_document_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_document_category_id ON public.documents USING btree (document_category_id);


--
-- Name: index_flags_on_flaggable_type_and_flaggable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flags_on_flaggable_type_and_flaggable_id ON public.flags USING btree (flaggable_type, flaggable_id);


--
-- Name: index_flags_on_resolved_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flags_on_resolved_by_id ON public.flags USING btree (resolved_by_id);


--
-- Name: index_flags_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_flags_on_user_id ON public.flags USING btree (user_id);


--
-- Name: index_ipums_records_on_histid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ipums_records_on_histid ON public.ipums_records USING btree (histid);


--
-- Name: index_localities_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_localities_on_slug ON public.localities USING btree (slug);


--
-- Name: index_localities_people_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_localities_people_on_locality_id ON public.localities_people USING btree (locality_id);


--
-- Name: index_localities_people_on_locality_id_and_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_localities_people_on_locality_id_and_person_id ON public.localities_people USING btree (locality_id, person_id);


--
-- Name: index_localities_people_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_localities_people_on_person_id ON public.localities_people USING btree (person_id);


--
-- Name: index_map_overlays_on_locality_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_map_overlays_on_locality_id ON public.map_overlays USING btree (locality_id);


--
-- Name: index_narratives_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_narratives_on_created_by_id ON public.narratives USING btree (created_by_id);


--
-- Name: index_narratives_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_narratives_on_reviewed_by_id ON public.narratives USING btree (reviewed_by_id);


--
-- Name: index_narratives_people_on_narrative_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_narratives_people_on_narrative_id ON public.narratives_people USING btree (narrative_id);


--
-- Name: index_narratives_people_on_narrative_id_and_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_narratives_people_on_narrative_id_and_person_id ON public.narratives_people USING btree (narrative_id, person_id);


--
-- Name: index_narratives_people_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_narratives_people_on_person_id ON public.narratives_people USING btree (person_id);


--
-- Name: index_people_videos_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_videos_on_person_id ON public.people_videos USING btree (person_id);


--
-- Name: index_people_videos_on_person_id_and_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_videos_on_person_id_and_video_id ON public.people_videos USING btree (person_id, video_id);


--
-- Name: index_people_videos_on_video_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_people_videos_on_video_id ON public.people_videos USING btree (video_id);


--
-- Name: index_person_names_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_person_names_on_person_id ON public.person_names USING btree (person_id);


--
-- Name: index_person_names_on_searchable_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_person_names_on_searchable_name ON public.person_names USING gin (searchable_name public.gin_trgm_ops);


--
-- Name: index_pg_search_documents_on_searchable_type_and_searchable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pg_search_documents_on_searchable_type_and_searchable_id ON public.pg_search_documents USING btree (searchable_type, searchable_id);


--
-- Name: index_photographs_on_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_photographs_on_building_id ON public.photographs USING btree (building_id);


--
-- Name: index_photographs_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_photographs_on_created_by_id ON public.photographs USING btree (created_by_id);


--
-- Name: index_photographs_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_photographs_on_reviewed_by_id ON public.photographs USING btree (reviewed_by_id);


--
-- Name: index_profession_subgroups_on_profession_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_profession_subgroups_on_profession_group_id ON public.profession_subgroups USING btree (profession_group_id);


--
-- Name: index_professions_on_profession_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_professions_on_profession_group_id ON public.professions USING btree (profession_group_id);


--
-- Name: index_professions_on_profession_subgroup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_professions_on_profession_subgroup_id ON public.professions USING btree (profession_subgroup_id);


--
-- Name: index_search_params_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_search_params_on_user_id ON public.search_params USING btree (user_id);


--
-- Name: index_settings_on_settings_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_settings_on_settings_group_id ON public.settings USING btree (settings_group_id);


--
-- Name: index_terms_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_terms_on_name ON public.terms USING btree (name);


--
-- Name: index_terms_on_vocabulary_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_terms_on_vocabulary_id ON public.terms USING btree (vocabulary_id);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON public.users USING btree (invitation_token);


--
-- Name: index_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_id ON public.users USING btree (invited_by_id);


--
-- Name: index_users_on_invited_by_type_and_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_type_and_invited_by_id ON public.users USING btree (invited_by_type, invited_by_id);


--
-- Name: index_users_on_user_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_user_group_id ON public.users USING btree (user_group_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON public.versions USING btree (item_type, item_id);


--
-- Name: index_videos_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_videos_on_created_by_id ON public.videos USING btree (created_by_id);


--
-- Name: index_videos_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_videos_on_reviewed_by_id ON public.videos USING btree (reviewed_by_id);


--
-- Name: index_vocabularies_on_machine_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vocabularies_on_machine_name ON public.vocabularies USING btree (machine_name);


--
-- Name: people_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX people_name_trgm ON public.people USING gist (searchable_name public.gist_trgm_ops);


--
-- Name: person_names_primary_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX person_names_primary_name_index ON public.person_names USING btree (person_id, is_primary);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: professions fk_rails_023df2be2a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professions
    ADD CONSTRAINT fk_rails_023df2be2a FOREIGN KEY (profession_group_id) REFERENCES public.profession_groups(id);


--
-- Name: census_1940_records fk_rails_06d9d88dc4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1940_records
    ADD CONSTRAINT fk_rails_06d9d88dc4 FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: settings fk_rails_10c1c8e1ec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT fk_rails_10c1c8e1ec FOREIGN KEY (settings_group_id) REFERENCES public.settings_groups(id);


--
-- Name: census_1850_records fk_rails_142bf2f784; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1850_records
    ADD CONSTRAINT fk_rails_142bf2f784 FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: videos fk_rails_168a3e4087; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.videos
    ADD CONSTRAINT fk_rails_168a3e4087 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: census_1860_records fk_rails_174c870b95; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1860_records
    ADD CONSTRAINT fk_rails_174c870b95 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: buildings fk_rails_19450252ab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT fk_rails_19450252ab FOREIGN KEY (parent_id) REFERENCES public.buildings(id);


--
-- Name: profession_subgroups fk_rails_1a62b1be4e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profession_subgroups
    ADD CONSTRAINT fk_rails_1a62b1be4e FOREIGN KEY (profession_group_id) REFERENCES public.profession_groups(id);


--
-- Name: census_1950_records fk_rails_1c7d3e9283; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1950_records
    ADD CONSTRAINT fk_rails_1c7d3e9283 FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: audit_logs fk_rails_1f26bc34ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT fk_rails_1f26bc34ae FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: bulk_updated_records fk_rails_22a17045eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_updated_records
    ADD CONSTRAINT fk_rails_22a17045eb FOREIGN KEY (bulk_update_id) REFERENCES public.bulk_updates(id);


--
-- Name: audios_buildings fk_rails_23fadd013c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audios_buildings
    ADD CONSTRAINT fk_rails_23fadd013c FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: census_1860_records fk_rails_25e3e35798; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1860_records
    ADD CONSTRAINT fk_rails_25e3e35798 FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: census_1950_records fk_rails_2cb4e0273e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1950_records
    ADD CONSTRAINT fk_rails_2cb4e0273e FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: census_1930_records fk_rails_2dae75f911; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1930_records
    ADD CONSTRAINT fk_rails_2dae75f911 FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: narratives_people fk_rails_34e8fcde8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.narratives_people
    ADD CONSTRAINT fk_rails_34e8fcde8b FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: bulk_updates fk_rails_35d0a740ec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_updates
    ADD CONSTRAINT fk_rails_35d0a740ec FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: census_1860_records fk_rails_3e6ad3533c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1860_records
    ADD CONSTRAINT fk_rails_3e6ad3533c FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: census_1850_records fk_rails_3fb36bbfc9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1850_records
    ADD CONSTRAINT fk_rails_3fb36bbfc9 FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: census_1950_records fk_rails_42a272a5a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1950_records
    ADD CONSTRAINT fk_rails_42a272a5a7 FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: census_1940_records fk_rails_42c21f87b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1940_records
    ADD CONSTRAINT fk_rails_42c21f87b5 FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: localities_people fk_rails_433a970f40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localities_people
    ADD CONSTRAINT fk_rails_433a970f40 FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: census_1870_records fk_rails_44b9e7970f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1870_records
    ADD CONSTRAINT fk_rails_44b9e7970f FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: census_1930_records fk_rails_45fc770121; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1930_records
    ADD CONSTRAINT fk_rails_45fc770121 FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: census_1900_records fk_rails_47391b920d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1900_records
    ADD CONSTRAINT fk_rails_47391b920d FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: audios fk_rails_49407cbc67; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audios
    ADD CONSTRAINT fk_rails_49407cbc67 FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: census_1900_records fk_rails_4a18bfd4c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1900_records
    ADD CONSTRAINT fk_rails_4a18bfd4c3 FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: annotations fk_rails_4b309a78a9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.annotations
    ADD CONSTRAINT fk_rails_4b309a78a9 FOREIGN KEY (map_overlay_id) REFERENCES public.map_overlays(id);


--
-- Name: census_1880_records fk_rails_4ca2e491a5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1880_records
    ADD CONSTRAINT fk_rails_4ca2e491a5 FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: census_1860_records fk_rails_4cac3249af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1860_records
    ADD CONSTRAINT fk_rails_4cac3249af FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: census_1910_records fk_rails_4fbfccdce2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1910_records
    ADD CONSTRAINT fk_rails_4fbfccdce2 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: census_1920_records fk_rails_5075b8d067; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1920_records
    ADD CONSTRAINT fk_rails_5075b8d067 FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: users fk_rails_5241793c6a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_5241793c6a FOREIGN KEY (user_group_id) REFERENCES public.user_groups(id);


--
-- Name: census_1950_records fk_rails_537eccb7b7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1950_records
    ADD CONSTRAINT fk_rails_537eccb7b7 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: person_names fk_rails_546377d8eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_names
    ADD CONSTRAINT fk_rails_546377d8eb FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: census_1900_records fk_rails_546952c24d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1900_records
    ADD CONSTRAINT fk_rails_546952c24d FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: search_params fk_rails_5a1475d615; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_params
    ADD CONSTRAINT fk_rails_5a1475d615 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: census_1850_records fk_rails_5c25bf0de2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1850_records
    ADD CONSTRAINT fk_rails_5c25bf0de2 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: audios fk_rails_5e3db79a87; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audios
    ADD CONSTRAINT fk_rails_5e3db79a87 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: terms fk_rails_6428f843c5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.terms
    ADD CONSTRAINT fk_rails_6428f843c5 FOREIGN KEY (vocabulary_id) REFERENCES public.vocabularies(id);


--
-- Name: buildings_videos fk_rails_6a2a310f59; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings_videos
    ADD CONSTRAINT fk_rails_6a2a310f59 FOREIGN KEY (video_id) REFERENCES public.videos(id);


--
-- Name: census_1940_records fk_rails_6ab4a16810; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1940_records
    ADD CONSTRAINT fk_rails_6ab4a16810 FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: census_1870_records fk_rails_6ba9a92057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1870_records
    ADD CONSTRAINT fk_rails_6ba9a92057 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: census_1920_records fk_rails_6bd420446a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1920_records
    ADD CONSTRAINT fk_rails_6bd420446a FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: census_1930_records fk_rails_6d8d9e58d0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1930_records
    ADD CONSTRAINT fk_rails_6d8d9e58d0 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: census_1930_records fk_rails_6dbc2f4282; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1930_records
    ADD CONSTRAINT fk_rails_6dbc2f4282 FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: census_1910_records fk_rails_6eebef98a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1910_records
    ADD CONSTRAINT fk_rails_6eebef98a8 FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: census_1880_records fk_rails_8168d169da; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1880_records
    ADD CONSTRAINT fk_rails_8168d169da FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: people_videos fk_rails_8183e99f47; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_videos
    ADD CONSTRAINT fk_rails_8183e99f47 FOREIGN KEY (video_id) REFERENCES public.videos(id);


--
-- Name: census_1870_records fk_rails_8536e65a56; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1870_records
    ADD CONSTRAINT fk_rails_8536e65a56 FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: map_overlays fk_rails_860b9573da; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.map_overlays
    ADD CONSTRAINT fk_rails_860b9573da FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: narratives_people fk_rails_864a92260f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.narratives_people
    ADD CONSTRAINT fk_rails_864a92260f FOREIGN KEY (narrative_id) REFERENCES public.narratives(id);


--
-- Name: annotations fk_rails_88814c38bd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.annotations
    ADD CONSTRAINT fk_rails_88814c38bd FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: professions fk_rails_8a459f18f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.professions
    ADD CONSTRAINT fk_rails_8a459f18f0 FOREIGN KEY (profession_subgroup_id) REFERENCES public.profession_subgroups(id);


--
-- Name: videos fk_rails_8cfa78eceb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.videos
    ADD CONSTRAINT fk_rails_8cfa78eceb FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: census_1900_records fk_rails_90ec9bfa05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1900_records
    ADD CONSTRAINT fk_rails_90ec9bfa05 FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: buildings fk_rails_9476d1ff0c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT fk_rails_9476d1ff0c FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: documents_localities fk_rails_97491e4cbe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents_localities
    ADD CONSTRAINT fk_rails_97491e4cbe FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: census_1930_records fk_rails_979a0fc38d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1930_records
    ADD CONSTRAINT fk_rails_979a0fc38d FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: census_1950_records fk_rails_992e3f98c6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1950_records
    ADD CONSTRAINT fk_rails_992e3f98c6 FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: census_1940_records fk_rails_9bc549db07; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1940_records
    ADD CONSTRAINT fk_rails_9bc549db07 FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: people_videos fk_rails_a2ccfc7446; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_videos
    ADD CONSTRAINT fk_rails_a2ccfc7446 FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: buildings fk_rails_a48daee42b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT fk_rails_a48daee42b FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: census_1850_records fk_rails_a4a4fc5011; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1850_records
    ADD CONSTRAINT fk_rails_a4a4fc5011 FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: localities_people fk_rails_a6372e6fac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.localities_people
    ADD CONSTRAINT fk_rails_a6372e6fac FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: addresses fk_rails_a9ab2347cc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT fk_rails_a9ab2347cc FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: census_1920_records fk_rails_ac957fdb8c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1920_records
    ADD CONSTRAINT fk_rails_ac957fdb8c FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: audios_people fk_rails_b47cac538e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audios_people
    ADD CONSTRAINT fk_rails_b47cac538e FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: buildings_videos fk_rails_b55dc50b22; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings_videos
    ADD CONSTRAINT fk_rails_b55dc50b22 FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: buildings fk_rails_b5f86c0789; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT fk_rails_b5f86c0789 FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: census_1860_records fk_rails_bbf99acd6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1860_records
    ADD CONSTRAINT fk_rails_bbf99acd6c FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: census_1910_records fk_rails_c44cb440f2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1910_records
    ADD CONSTRAINT fk_rails_c44cb440f2 FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: census_1900_records fk_rails_c864f6e26b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1900_records
    ADD CONSTRAINT fk_rails_c864f6e26b FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: documents_localities fk_rails_c8cee96948; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents_localities
    ADD CONSTRAINT fk_rails_c8cee96948 FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: buildings_narratives fk_rails_c972f4349e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings_narratives
    ADD CONSTRAINT fk_rails_c972f4349e FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: photographs fk_rails_c9d92c9b36; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photographs
    ADD CONSTRAINT fk_rails_c9d92c9b36 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: census_1920_records fk_rails_cba05634b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1920_records
    ADD CONSTRAINT fk_rails_cba05634b9 FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- Name: narratives fk_rails_ccc494e6a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.narratives
    ADD CONSTRAINT fk_rails_ccc494e6a8 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: narratives fk_rails_cd47849580; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.narratives
    ADD CONSTRAINT fk_rails_cd47849580 FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: census_1880_records fk_rails_cecea9810a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1880_records
    ADD CONSTRAINT fk_rails_cecea9810a FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: census_1910_records fk_rails_cf66a80d45; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1910_records
    ADD CONSTRAINT fk_rails_cf66a80d45 FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: census_1870_records fk_rails_d28b503022; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1870_records
    ADD CONSTRAINT fk_rails_d28b503022 FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: flags fk_rails_d2e998acee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT fk_rails_d2e998acee FOREIGN KEY (resolved_by_id) REFERENCES public.users(id);


--
-- Name: census_1930_records fk_rails_d42ebea834; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1930_records
    ADD CONSTRAINT fk_rails_d42ebea834 FOREIGN KEY (industry1930_code_id) REFERENCES public.industry1930_codes(id);


--
-- Name: census_1940_records fk_rails_d6f4ba936a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1940_records
    ADD CONSTRAINT fk_rails_d6f4ba936a FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: flags fk_rails_d7842de637; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flags
    ADD CONSTRAINT fk_rails_d7842de637 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: audios_people fk_rails_dccfd2a82e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audios_people
    ADD CONSTRAINT fk_rails_dccfd2a82e FOREIGN KEY (audio_id) REFERENCES public.audios(id);


--
-- Name: buildings_narratives fk_rails_e44861af48; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings_narratives
    ADD CONSTRAINT fk_rails_e44861af48 FOREIGN KEY (narrative_id) REFERENCES public.narratives(id);


--
-- Name: photographs fk_rails_e6b14fa648; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photographs
    ADD CONSTRAINT fk_rails_e6b14fa648 FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: census_1870_records fk_rails_ea49f2b39b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1870_records
    ADD CONSTRAINT fk_rails_ea49f2b39b FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: census_1880_records fk_rails_ec91bb0298; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1880_records
    ADD CONSTRAINT fk_rails_ec91bb0298 FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: audios_buildings fk_rails_edfb751506; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audios_buildings
    ADD CONSTRAINT fk_rails_edfb751506 FOREIGN KEY (audio_id) REFERENCES public.audios(id);


--
-- Name: census_1920_records fk_rails_eeb4b2f9b7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1920_records
    ADD CONSTRAINT fk_rails_eeb4b2f9b7 FOREIGN KEY (locality_id) REFERENCES public.localities(id);


--
-- Name: census_1930_records fk_rails_f00a20aa20; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1930_records
    ADD CONSTRAINT fk_rails_f00a20aa20 FOREIGN KEY (occupation1930_code_id) REFERENCES public.occupation1930_codes(id);


--
-- Name: documents fk_rails_f078ae7115; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_rails_f078ae7115 FOREIGN KEY (document_category_id) REFERENCES public.document_categories(id);


--
-- Name: cms_page_widgets fk_rails_fddba18ae5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_page_widgets
    ADD CONSTRAINT fk_rails_fddba18ae5 FOREIGN KEY (cms_page_id) REFERENCES public.cms_pages(id);


--
-- Name: census_1850_records fk_rails_fe74ae03d0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1850_records
    ADD CONSTRAINT fk_rails_fe74ae03d0 FOREIGN KEY (person_id) REFERENCES public.people(id);


--
-- Name: census_1910_records fk_rails_fe9240d7fc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1910_records
    ADD CONSTRAINT fk_rails_fe9240d7fc FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: census_1880_records fk_rails_ff758ae873; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.census_1880_records
    ADD CONSTRAINT fk_rails_ff758ae873 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: photographs fk_rails_ffeb8175e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.photographs
    ADD CONSTRAINT fk_rails_ffeb8175e1 FOREIGN KEY (building_id) REFERENCES public.buildings(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('9'),
('8'),
('4'),
('20241124000534'),
('20240824170019'),
('20240818214339'),
('20240818182508'),
('20240603010233'),
('20240527212417'),
('20240527193323'),
('20240525212124'),
('20240525211855'),
('20240525211843'),
('20240317204603'),
('20240131130547'),
('20240130130704'),
('20240130125143'),
('20240128190924'),
('20240122140922'),
('20240122134440'),
('20240121141010'),
('20240117020347'),
('20231224022917'),
('20231223181402'),
('20231221024555'),
('20231219030352'),
('20231219022737'),
('20231105171039'),
('20231105155617'),
('20231016225407'),
('20231015225421'),
('20231015223752'),
('20231014205808'),
('20230806222223'),
('20230709002649'),
('20230702224640'),
('20230702224634'),
('20230702224623'),
('20230430231531'),
('20230430171534'),
('20230319030813'),
('20230318221021'),
('20230116161711'),
('20230115211545'),
('20221030214744'),
('20221030210941'),
('20221010000542'),
('20221009233017'),
('20221003014844'),
('20221003012823'),
('20221003000851'),
('20220925204437'),
('20220806213952'),
('20220806212151'),
('20220617012437'),
('20220614013215'),
('20220614011502'),
('20220604234821'),
('20220205165522'),
('20220122173902'),
('20220122173901'),
('20220122173900'),
('20220117003248'),
('20220116235637'),
('20220116212509'),
('20211215194727'),
('20211115012130'),
('20210930074328'),
('20210924193543'),
('20210915202210'),
('20210913184616'),
('20210913171533'),
('20210913141230'),
('20210903004009'),
('20210827201710'),
('20210826212926'),
('20210821190633'),
('20210821180105'),
('20210818205926'),
('20210811185354'),
('20210730214839'),
('20210726141221'),
('20210719173748'),
('20210627143657'),
('20210620020601'),
('20210619135540'),
('20210618213807'),
('20210617171815'),
('20210617014230'),
('20210615213909'),
('20210615213055'),
('20210615212156'),
('20210615165015'),
('20210615144735'),
('20210614162626'),
('20210609163131'),
('20210314004904'),
('20210314004739'),
('20210313231059'),
('20210131173131'),
('20210130200946'),
('20210130200740'),
('20210130185420'),
('20210130172155'),
('20210107185645'),
('20201219162840'),
('20201219161442'),
('20201212224033'),
('20201207010511'),
('20201122212348'),
('20201122165759'),
('20201122013216'),
('20201121222208'),
('20201115220300'),
('20200924194952'),
('20200914132614'),
('20200914004852'),
('20200831185905'),
('20200718201759'),
('20200614162330'),
('20200502143910'),
('20200428132809'),
('20200427210720'),
('20200419191715'),
('20200417193045'),
('20200417002329'),
('20200416212754'),
('20200416212207'),
('20200416155130'),
('20200415174638'),
('20200415145733'),
('20200414232728'),
('20200414204050'),
('20200414171322'),
('20200410154914'),
('20200410010352'),
('20200410005318'),
('20200409154719'),
('20200408162359'),
('20200408152619'),
('20200408141512'),
('20200408141449'),
('20200408141423'),
('20200408134033'),
('20200407203920'),
('20200407203909'),
('20200407161313'),
('20200406211733'),
('20200406211649'),
('20200406191653'),
('20200224130113'),
('20200220200131'),
('20200220195438'),
('20200220195054'),
('20200220191632'),
('20200124144150'),
('20191220211754'),
('20191220210841'),
('20191202153328'),
('20191115203033'),
('20191115203032'),
('20191114210951'),
('20191114192820'),
('20191112141252'),
('20191015164038'),
('20191015162449'),
('20191015162122'),
('20190829213843'),
('20190829184946'),
('20180617224740'),
('20180617224739'),
('20180128223838'),
('20171028031007'),
('20171002235012'),
('20171002123353'),
('20170929135029'),
('20170929133413'),
('20170928160042'),
('20170921123744'),
('20170918124344'),
('20170115043803'),
('20170115041924'),
('20170115034657'),
('20170115023907'),
('20170114173515'),
('20170114163726'),
('20161207133016'),
('20161205134509'),
('20160806153456'),
('20160422212753'),
('20160422212620'),
('20160408122856'),
('20160407122307'),
('20160331124523'),
('20160310134259'),
('20160310133650'),
('20160304193032'),
('20160304132238'),
('20160301134243'),
('20160226152459'),
('20160226144814'),
('20160224131809'),
('20150424134733'),
('20140819173754'),
('20140814115719'),
('20140723210039'),
('20140723210038'),
('20140723210037'),
('20140723210036'),
('20140716133209'),
('20140707165304'),
('20110626154733'),
('20101017144450'),
('20101010150230'),
('20100902175820'),
('20100902173417'),
('20100830140138'),
('20100829235006'),
('20100809131346'),
('20100809115118'),
('20100802161012'),
('20100802160932'),
('20100724222024'),
('20100724213721'),
('20100723180339'),
('20100723175313'),
('20100723145630'),
('20100722165440'),
('20100523153742'),
('20100502171002'),
('20100428160814'),
('20100424144145'),
('20100424143713'),
('20090509172858'),
('20090507163648'),
('20090302214746'),
('20090302181026'),
('20090225160647'),
('20090225160349'),
('20090217124203'),
('20090202223821'),
('20090119123246'),
('20081218152649'),
('20081216211959'),
('15'),
('12'),
('11'),
('10'),
('1');

