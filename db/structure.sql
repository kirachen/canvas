--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: delayed_jobs_after_delete_row_tr_fn(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delayed_jobs_after_delete_row_tr_fn() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        PERFORM pg_advisory_xact_lock(half_md5_as_bigint(OLD.strand));
        UPDATE delayed_jobs SET next_in_strand = 't' WHERE id = (SELECT id FROM delayed_jobs j2 WHERE j2.strand = OLD.strand ORDER BY j2.strand, j2.id ASC LIMIT 1 FOR UPDATE);
        RETURN OLD;
      END;
      $$;


--
-- Name: delayed_jobs_before_insert_row_tr_fn(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delayed_jobs_before_insert_row_tr_fn() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        PERFORM pg_advisory_xact_lock(half_md5_as_bigint(NEW.strand));
        IF (SELECT 1 FROM delayed_jobs WHERE strand = NEW.strand LIMIT 1) = 1 THEN
          NEW.next_in_strand := 'f';
        END IF;
        RETURN NEW;
      END;
      $$;


--
-- Name: half_md5_as_bigint(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION half_md5_as_bigint(strand character varying) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
      DECLARE
        strand_md5 bytea;
      BEGIN
        strand_md5 := decode(md5(strand), 'hex');
        RETURN (CAST(get_byte(strand_md5, 0) AS bigint) << 56) +
                                  (CAST(get_byte(strand_md5, 1) AS bigint) << 48) +
                                  (CAST(get_byte(strand_md5, 2) AS bigint) << 40) +
                                  (CAST(get_byte(strand_md5, 3) AS bigint) << 32) +
                                  (CAST(get_byte(strand_md5, 4) AS bigint) << 24) +
                                  (get_byte(strand_md5, 5) << 16) +
                                  (get_byte(strand_md5, 6) << 8) +
                                   get_byte(strand_md5, 7);
      END;
      $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: abstract_courses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE abstract_courses (
    id bigint NOT NULL,
    sis_source_id character varying(255),
    sis_batch_id bigint,
    account_id bigint NOT NULL,
    root_account_id bigint NOT NULL,
    short_name character varying(255),
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    enrollment_term_id bigint NOT NULL,
    workflow_state character varying(255) NOT NULL,
    stuck_sis_fields text
);


--
-- Name: abstract_courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE abstract_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: abstract_courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE abstract_courses_id_seq OWNED BY abstract_courses.id;


--
-- Name: access_tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE access_tokens (
    id bigint NOT NULL,
    developer_key_id bigint,
    user_id bigint,
    last_used_at timestamp without time zone,
    expires_at timestamp without time zone,
    purpose character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    crypted_token character varying(255),
    token_hint character varying(255),
    scopes text,
    remember_access boolean
);


--
-- Name: access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE access_tokens_id_seq OWNED BY access_tokens.id;


--
-- Name: account_authorization_configs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_authorization_configs (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    auth_port integer,
    auth_host character varying(255),
    auth_base character varying(255),
    auth_username character varying(255),
    auth_crypted_password character varying(255),
    auth_password_salt character varying(255),
    auth_type character varying(255),
    auth_over_tls character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    log_in_url character varying(255),
    log_out_url character varying(255),
    identifier_format character varying(255),
    certificate_fingerprint text,
    entity_id character varying(255),
    change_password_url character varying(255),
    login_handle_name character varying(255),
    auth_filter character varying(255),
    requested_authn_context character varying(255),
    last_timeout_failure timestamp without time zone,
    login_attribute text,
    idp_entity_id character varying(255),
    "position" integer,
    unknown_user_url character varying(255)
);


--
-- Name: account_authorization_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_authorization_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_authorization_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_authorization_configs_id_seq OWNED BY account_authorization_configs.id;


--
-- Name: account_notification_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_notification_roles (
    id bigint NOT NULL,
    account_notification_id bigint NOT NULL,
    role_id bigint
);


--
-- Name: account_notification_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_notification_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_notification_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_notification_roles_id_seq OWNED BY account_notification_roles.id;


--
-- Name: account_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_notifications (
    id bigint NOT NULL,
    subject character varying(255),
    icon character varying(255) DEFAULT 'warning'::character varying,
    message text,
    account_id bigint NOT NULL,
    user_id bigint,
    start_at timestamp without time zone NOT NULL,
    end_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    required_account_service character varying(255),
    months_in_display_cycle integer
);


--
-- Name: account_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_notifications_id_seq OWNED BY account_notifications.id;


--
-- Name: account_reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_reports (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    message text,
    account_id bigint NOT NULL,
    attachment_id bigint,
    workflow_state character varying(255) DEFAULT 'created'::character varying NOT NULL,
    report_type character varying(255),
    progress integer,
    start_at date,
    end_at date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    parameters text
);


--
-- Name: account_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_reports_id_seq OWNED BY account_reports.id;


--
-- Name: account_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE account_users (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    role_id bigint NOT NULL
);


--
-- Name: account_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE account_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE account_users_id_seq OWNED BY account_users.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id bigint NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    workflow_state character varying(255) DEFAULT 'active'::character varying NOT NULL,
    deleted_at timestamp without time zone,
    parent_account_id bigint,
    sis_source_id character varying(255),
    sis_batch_id bigint,
    current_sis_batch_id bigint,
    root_account_id bigint,
    last_successful_sis_batch_id bigint,
    membership_types character varying(255),
    require_authorization_code boolean,
    default_time_zone character varying(255),
    external_status character varying(255) DEFAULT 'active'::character varying,
    storage_quota bigint,
    default_storage_quota bigint,
    enable_user_notes boolean DEFAULT false,
    allowed_services character varying(255),
    turnitin_pledge text,
    turnitin_comments text,
    turnitin_account_id character varying(255),
    turnitin_salt character varying(255),
    turnitin_crypted_secret character varying(255),
    show_section_name_as_course_name boolean DEFAULT false,
    allow_sis_import boolean DEFAULT false,
    equella_endpoint character varying(255),
    settings text,
    uuid character varying(255),
    default_locale character varying(255),
    stuck_sis_fields text,
    default_user_storage_quota bigint,
    lti_guid character varying(255),
    default_group_storage_quota bigint,
    turnitin_host character varying(255),
    integration_id character varying(255),
    lti_context_id character varying(255)
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: alert_criteria; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE alert_criteria (
    id bigint NOT NULL,
    alert_id bigint,
    criterion_type character varying(255),
    threshold double precision
);


--
-- Name: alert_criteria_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE alert_criteria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alert_criteria_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE alert_criteria_id_seq OWNED BY alert_criteria.id;


--
-- Name: alerts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE alerts (
    id bigint NOT NULL,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    recipients text NOT NULL,
    repetition integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE alerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE alerts_id_seq OWNED BY alerts.id;


--
-- Name: appointment_group_contexts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE appointment_group_contexts (
    id bigint NOT NULL,
    appointment_group_id bigint,
    context_code character varying(255),
    context_id bigint,
    context_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: appointment_group_contexts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE appointment_group_contexts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appointment_group_contexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE appointment_group_contexts_id_seq OWNED BY appointment_group_contexts.id;


--
-- Name: appointment_group_sub_contexts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE appointment_group_sub_contexts (
    id bigint NOT NULL,
    appointment_group_id bigint,
    sub_context_id bigint,
    sub_context_type character varying(255),
    sub_context_code character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: appointment_group_sub_contexts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE appointment_group_sub_contexts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appointment_group_sub_contexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE appointment_group_sub_contexts_id_seq OWNED BY appointment_group_sub_contexts.id;


--
-- Name: appointment_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE appointment_groups (
    id bigint NOT NULL,
    title character varying(255),
    description text,
    location_name character varying(255),
    location_address character varying(255),
    context_id bigint,
    context_type character varying(255),
    context_code character varying(255),
    sub_context_id bigint,
    sub_context_type character varying(255),
    sub_context_code character varying(255),
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    participants_per_appointment integer,
    max_appointments_per_participant integer,
    min_appointments_per_participant integer DEFAULT 0,
    participant_visibility character varying(255)
);


--
-- Name: appointment_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE appointment_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appointment_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE appointment_groups_id_seq OWNED BY appointment_groups.id;


--
-- Name: assessment_question_bank_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assessment_question_bank_users (
    id bigint NOT NULL,
    assessment_question_bank_id bigint NOT NULL,
    user_id bigint NOT NULL,
    permissions character varying(255),
    workflow_state character varying(255) NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: assessment_question_bank_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assessment_question_bank_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_question_bank_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assessment_question_bank_users_id_seq OWNED BY assessment_question_bank_users.id;


--
-- Name: assessment_question_banks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assessment_question_banks (
    id bigint NOT NULL,
    context_id bigint,
    context_type character varying(255),
    title text,
    workflow_state character varying(255) NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    migration_id character varying(255)
);


--
-- Name: assessment_question_banks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assessment_question_banks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_question_banks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assessment_question_banks_id_seq OWNED BY assessment_question_banks.id;


--
-- Name: assessment_questions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assessment_questions (
    id bigint NOT NULL,
    name text,
    question_data text,
    context_id bigint,
    context_type character varying(255),
    workflow_state character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    assessment_question_bank_id bigint,
    deleted_at timestamp without time zone,
    migration_id character varying(255),
    "position" integer
);


--
-- Name: assessment_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assessment_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assessment_questions_id_seq OWNED BY assessment_questions.id;


--
-- Name: assessment_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assessment_requests (
    id bigint NOT NULL,
    rubric_assessment_id bigint,
    user_id bigint NOT NULL,
    asset_id bigint NOT NULL,
    asset_type character varying(255) NOT NULL,
    assessor_asset_id bigint NOT NULL,
    assessor_asset_type character varying(255) NOT NULL,
    comments text,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid character varying(255),
    rubric_association_id bigint,
    assessor_id bigint NOT NULL
);


--
-- Name: assessment_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assessment_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assessment_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assessment_requests_id_seq OWNED BY assessment_requests.id;


--
-- Name: asset_user_accesses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE asset_user_accesses (
    id bigint NOT NULL,
    asset_code character varying(255),
    asset_group_code character varying(255),
    user_id bigint,
    context_id bigint,
    context_type character varying(255),
    last_access timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    asset_category character varying(255),
    view_score double precision,
    participate_score double precision,
    action_level character varying(255),
    summarized_at timestamp without time zone,
    display_name text,
    membership_type character varying(255)
);


--
-- Name: asset_user_accesses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE asset_user_accesses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asset_user_accesses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE asset_user_accesses_id_seq OWNED BY asset_user_accesses.id;


--
-- Name: assignment_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assignment_groups (
    id bigint NOT NULL,
    name character varying(255),
    rules text,
    default_assignment_name character varying(255),
    "position" integer,
    assignment_weighting_scheme character varying(255),
    group_weight double precision,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    cloned_item_id bigint,
    context_code character varying(255),
    migration_id character varying(255)
);


--
-- Name: assignment_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assignment_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignment_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assignment_groups_id_seq OWNED BY assignment_groups.id;


--
-- Name: assignment_override_students; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assignment_override_students (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    assignment_id bigint,
    assignment_override_id bigint NOT NULL,
    user_id bigint NOT NULL,
    quiz_id bigint
);


--
-- Name: assignment_override_students_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assignment_override_students_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignment_override_students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assignment_override_students_id_seq OWNED BY assignment_override_students.id;


--
-- Name: assignment_overrides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assignment_overrides (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    assignment_id bigint,
    assignment_version integer,
    set_type character varying(255),
    set_id bigint,
    title character varying(255) NOT NULL,
    workflow_state character varying(255) NOT NULL,
    due_at_overridden boolean DEFAULT false NOT NULL,
    due_at timestamp without time zone,
    all_day boolean,
    all_day_date date,
    unlock_at_overridden boolean DEFAULT false NOT NULL,
    unlock_at timestamp without time zone,
    lock_at_overridden boolean DEFAULT false NOT NULL,
    lock_at timestamp without time zone,
    quiz_id bigint,
    quiz_version integer
);


--
-- Name: assignment_overrides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assignment_overrides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignment_overrides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assignment_overrides_id_seq OWNED BY assignment_overrides.id;


--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assignments (
    id bigint NOT NULL,
    title character varying(255),
    description text,
    due_at timestamp without time zone,
    unlock_at timestamp without time zone,
    lock_at timestamp without time zone,
    points_possible double precision,
    min_score double precision,
    max_score double precision,
    mastery_score double precision,
    grading_type character varying(255),
    submission_types character varying(255),
    workflow_state character varying(255) NOT NULL,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    assignment_group_id bigint,
    grading_scheme_id bigint,
    grading_standard_id bigint,
    location character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    group_category character varying(255),
    submissions_downloads integer DEFAULT 0,
    peer_review_count integer DEFAULT 0,
    peer_reviews_due_at timestamp without time zone,
    peer_reviews_assigned boolean DEFAULT false,
    peer_reviews boolean DEFAULT false,
    automatic_peer_reviews boolean DEFAULT false,
    all_day boolean,
    all_day_date date,
    could_be_locked boolean,
    cloned_item_id bigint,
    context_code character varying(255),
    "position" integer,
    migration_id character varying(255),
    grade_group_students_individually boolean,
    anonymous_peer_reviews boolean,
    time_zone_edited character varying(255),
    turnitin_enabled boolean,
    allowed_extensions character varying(255),
    needs_grading_count integer DEFAULT 0,
    turnitin_settings text,
    muted boolean DEFAULT false,
    group_category_id bigint,
    freeze_on_copy boolean,
    copied boolean,
    only_visible_to_overrides boolean,
    post_to_sis boolean,
    integration_id character varying(255),
    integration_data text
);


--
-- Name: course_sections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE course_sections (
    id bigint NOT NULL,
    sis_source_id character varying(255),
    sis_batch_id bigint,
    course_id bigint NOT NULL,
    root_account_id bigint NOT NULL,
    enrollment_term_id bigint,
    name character varying(255) NOT NULL,
    default_section boolean,
    accepting_enrollments boolean,
    can_manually_enroll boolean,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    workflow_state character varying(255) DEFAULT 'active'::character varying NOT NULL,
    restrict_enrollments_to_section_dates boolean,
    nonxlist_course_id bigint,
    stuck_sis_fields text,
    integration_id character varying(255)
);


--
-- Name: courses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE courses (
    id bigint NOT NULL,
    name character varying(255),
    account_id bigint NOT NULL,
    group_weighting_scheme character varying(255),
    old_account_id bigint,
    workflow_state character varying(255) NOT NULL,
    uuid character varying(255),
    start_at timestamp without time zone,
    conclude_at timestamp without time zone,
    grading_standard_id bigint,
    is_public boolean,
    allow_student_wiki_edits boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    show_public_context_messages boolean,
    syllabus_body text,
    allow_student_forum_attachments boolean DEFAULT false,
    default_wiki_editing_roles character varying(255),
    wiki_id bigint,
    allow_student_organized_groups boolean DEFAULT true,
    course_code character varying(255),
    default_view character varying(255) DEFAULT 'feed'::character varying,
    abstract_course_id bigint,
    root_account_id bigint NOT NULL,
    enrollment_term_id bigint NOT NULL,
    sis_source_id character varying(255),
    sis_batch_id bigint,
    show_all_discussion_entries boolean,
    open_enrollment boolean,
    storage_quota bigint,
    tab_configuration text,
    allow_wiki_comments boolean,
    turnitin_comments text,
    self_enrollment boolean,
    license character varying(255),
    indexed boolean,
    restrict_enrollments_to_course_dates boolean,
    template_course_id bigint,
    locale character varying(255),
    settings text,
    replacement_course_id bigint,
    stuck_sis_fields text,
    public_description text,
    self_enrollment_code character varying(255),
    self_enrollment_limit integer,
    integration_id character varying(255),
    time_zone character varying(255),
    lti_context_id character varying(255)
);


--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE enrollments (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    course_id bigint NOT NULL,
    type character varying(255) NOT NULL,
    uuid character varying(255),
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    associated_user_id bigint,
    sis_source_id character varying(255),
    sis_batch_id bigint,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    course_section_id bigint NOT NULL,
    root_account_id bigint NOT NULL,
    computed_final_score double precision,
    completed_at timestamp without time zone,
    self_enrolled boolean,
    computed_current_score double precision,
    grade_publishing_status character varying(255) DEFAULT 'unpublished'::character varying,
    last_publish_attempt_at timestamp without time zone,
    stuck_sis_fields text,
    grade_publishing_message text,
    limit_privileges_to_course_section boolean,
    last_activity_at timestamp without time zone,
    total_activity_time integer,
    role_id bigint NOT NULL
);


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE submissions (
    id bigint NOT NULL,
    body text,
    url character varying(255),
    attachment_id bigint,
    grade character varying(255),
    score double precision,
    submitted_at timestamp without time zone,
    assignment_id bigint NOT NULL,
    user_id bigint NOT NULL,
    submission_type character varying(255),
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    group_id bigint,
    attachment_ids text,
    processed boolean,
    process_attempts integer DEFAULT 0,
    grade_matches_current_submission boolean,
    published_score double precision,
    published_grade character varying(255),
    graded_at timestamp without time zone,
    student_entered_score double precision,
    grader_id bigint,
    media_comment_id character varying(255),
    media_comment_type character varying(255),
    quiz_submission_id bigint,
    submission_comments_count integer,
    has_rubric_assessment boolean,
    attempt integer,
    context_code character varying(255),
    media_object_id bigint,
    turnitin_data text,
    has_admin_comment boolean DEFAULT false NOT NULL,
    cached_due_date timestamp without time zone
);


--
-- Name: assignment_student_visibilities; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW assignment_student_visibilities AS
 SELECT DISTINCT a.id AS assignment_id,
    e.user_id,
    c.id AS course_id
   FROM (((((assignments a
     JOIN courses c ON (((a.context_id = c.id) AND ((a.context_type)::text = 'Course'::text))))
     JOIN enrollments e ON ((((e.course_id = c.id) AND ((e.type)::text = ANY ((ARRAY['StudentEnrollment'::character varying, 'StudentViewEnrollment'::character varying])::text[]))) AND ((e.workflow_state)::text <> 'deleted'::text))))
     JOIN course_sections cs ON (((cs.course_id = c.id) AND (e.course_section_id = cs.id))))
     LEFT JOIN assignment_overrides ao ON (((((ao.assignment_id = a.id) AND ((ao.workflow_state)::text = 'active'::text)) AND ((ao.set_type)::text = 'CourseSection'::text)) AND (ao.set_id = cs.id))))
     LEFT JOIN submissions s ON ((((s.user_id = e.user_id) AND (s.assignment_id = a.id)) AND (s.score IS NOT NULL))))
  WHERE (((a.workflow_state)::text <> ALL ((ARRAY['deleted'::character varying, 'unpublished'::character varying])::text[])) AND (((a.only_visible_to_overrides = true) AND ((ao.id IS NOT NULL) OR (s.id IS NOT NULL))) OR (COALESCE(a.only_visible_to_overrides, false) = false)));


--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assignments_id_seq OWNED BY assignments.id;


--
-- Name: attachment_associations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE attachment_associations (
    id bigint NOT NULL,
    attachment_id bigint,
    context_id bigint,
    context_type character varying(255)
);


--
-- Name: attachment_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attachment_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachment_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE attachment_associations_id_seq OWNED BY attachment_associations.id;


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE attachments (
    id bigint NOT NULL,
    context_id bigint,
    context_type character varying(255),
    size bigint,
    folder_id bigint,
    content_type character varying(255),
    filename text,
    uuid character varying(255),
    display_name text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    workflow_state character varying(255),
    user_id bigint,
    local_filename character varying(255),
    locked boolean DEFAULT false,
    file_state character varying(255),
    deleted_at timestamp without time zone,
    "position" integer,
    lock_at timestamp without time zone,
    unlock_at timestamp without time zone,
    last_lock_at timestamp without time zone,
    last_unlock_at timestamp without time zone,
    could_be_locked boolean,
    root_attachment_id bigint,
    cloned_item_id bigint,
    migration_id character varying(255),
    namespace character varying(255),
    media_entry_id character varying(255),
    md5 character varying(255),
    encoding character varying(255),
    need_notify boolean,
    upload_error_message character varying(255),
    last_inline_view timestamp without time zone,
    replacement_attachment_id bigint,
    usage_rights_id bigint
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE attachments_id_seq OWNED BY attachments.id;


--
-- Name: authorization_codes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authorization_codes (
    id bigint NOT NULL,
    authorization_code character varying(255),
    authorization_service character varying(255),
    account_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    associated_account_id bigint
);


--
-- Name: authorization_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authorization_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authorization_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authorization_codes_id_seq OWNED BY authorization_codes.id;


--
-- Name: calendar_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE calendar_events (
    id bigint NOT NULL,
    title character varying(255),
    description text,
    location_name character varying(255),
    location_address character varying(255),
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id bigint,
    all_day boolean,
    all_day_date date,
    deleted_at timestamp without time zone,
    cloned_item_id bigint,
    context_code character varying(255),
    migration_id character varying(255),
    time_zone_edited character varying(255),
    parent_calendar_event_id bigint,
    effective_context_code character varying(255),
    participants_per_appointment integer,
    override_participants_per_appointment boolean
);


--
-- Name: calendar_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE calendar_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: calendar_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE calendar_events_id_seq OWNED BY calendar_events.id;


--
-- Name: canvadocs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE canvadocs (
    id bigint NOT NULL,
    document_id character varying(255),
    process_state character varying(255),
    attachment_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: canvadocs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE canvadocs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: canvadocs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE canvadocs_id_seq OWNED BY canvadocs.id;


--
-- Name: cloned_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cloned_items (
    id bigint NOT NULL,
    original_item_id bigint,
    original_item_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cloned_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cloned_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cloned_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cloned_items_id_seq OWNED BY cloned_items.id;


--
-- Name: collaborations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collaborations (
    id bigint NOT NULL,
    collaboration_type character varying(255),
    document_id character varying(255),
    user_id bigint,
    context_id bigint,
    context_type character varying(255),
    url character varying(255),
    uuid character varying(255),
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description text,
    title character varying(255) NOT NULL,
    workflow_state character varying(255) DEFAULT 'active'::character varying NOT NULL,
    deleted_at timestamp without time zone,
    context_code character varying(255),
    type character varying(255)
);


--
-- Name: collaborations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collaborations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collaborations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collaborations_id_seq OWNED BY collaborations.id;


--
-- Name: collaborators; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collaborators (
    id bigint NOT NULL,
    user_id bigint,
    collaboration_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    authorized_service_user_id character varying(255),
    group_id bigint
);


--
-- Name: collaborators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE collaborators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collaborators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE collaborators_id_seq OWNED BY collaborators.id;


--
-- Name: communication_channels; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE communication_channels (
    id bigint NOT NULL,
    path character varying(255) NOT NULL,
    path_type character varying(255) DEFAULT 'email'::character varying NOT NULL,
    "position" integer,
    user_id bigint NOT NULL,
    pseudonym_id bigint,
    bounce_count integer DEFAULT 0,
    workflow_state character varying(255) NOT NULL,
    confirmation_code character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    build_pseudonym_on_confirm boolean,
    access_token_id bigint,
    internal_path character varying(255)
);


--
-- Name: communication_channels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE communication_channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: communication_channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE communication_channels_id_seq OWNED BY communication_channels.id;


--
-- Name: content_exports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_exports (
    id bigint NOT NULL,
    user_id bigint,
    attachment_id bigint,
    export_type character varying(255),
    settings text,
    progress double precision,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    content_migration_id bigint,
    context_type character varying(255),
    context_id bigint
);


--
-- Name: content_exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_exports_id_seq OWNED BY content_exports.id;


--
-- Name: content_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_migrations (
    id bigint NOT NULL,
    context_id bigint NOT NULL,
    user_id bigint,
    workflow_state character varying(255) NOT NULL,
    migration_settings character varying(512000),
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    progress double precision,
    context_type character varying(255),
    error_count integer,
    error_data text,
    attachment_id bigint,
    overview_attachment_id bigint,
    exported_attachment_id bigint,
    source_course_id bigint,
    migration_type character varying(255)
);


--
-- Name: content_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_migrations_id_seq OWNED BY content_migrations.id;


--
-- Name: content_participation_counts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_participation_counts (
    id bigint NOT NULL,
    content_type character varying(255),
    context_type character varying(255),
    context_id bigint,
    user_id bigint,
    unread_count integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: content_participation_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_participation_counts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_participation_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_participation_counts_id_seq OWNED BY content_participation_counts.id;


--
-- Name: content_participations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_participations (
    id bigint NOT NULL,
    content_type character varying(255) NOT NULL,
    content_id bigint NOT NULL,
    user_id bigint NOT NULL,
    workflow_state character varying(255) NOT NULL
);


--
-- Name: content_participations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_participations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_participations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_participations_id_seq OWNED BY content_participations.id;


--
-- Name: content_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE content_tags (
    id bigint NOT NULL,
    content_id bigint,
    content_type character varying(255),
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    title text,
    tag character varying(255),
    url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    comments text,
    tag_type character varying(255) DEFAULT 'default'::character varying,
    context_module_id bigint,
    "position" integer,
    indent integer,
    migration_id character varying(255),
    learning_outcome_id bigint,
    context_code character varying(255),
    mastery_score double precision,
    rubric_association_id bigint,
    workflow_state character varying(255) DEFAULT 'active'::character varying NOT NULL,
    cloned_item_id bigint,
    associated_asset_id bigint,
    associated_asset_type character varying(255),
    new_tab boolean
);


--
-- Name: content_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE content_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE content_tags_id_seq OWNED BY content_tags.id;


--
-- Name: context_external_tool_placements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE context_external_tool_placements (
    id bigint NOT NULL,
    placement_type character varying(255),
    context_external_tool_id bigint NOT NULL
);


--
-- Name: context_external_tool_placements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE context_external_tool_placements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: context_external_tool_placements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE context_external_tool_placements_id_seq OWNED BY context_external_tool_placements.id;


--
-- Name: context_external_tools; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE context_external_tools (
    id bigint NOT NULL,
    context_id bigint,
    context_type character varying(255),
    domain character varying(255),
    url character varying(4096),
    shared_secret text NOT NULL,
    consumer_key text NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    settings text,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    migration_id character varying(255),
    cloned_item_id bigint,
    tool_id character varying(255),
    integration_type character varying(255),
    not_selectable boolean
);


--
-- Name: context_external_tools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE context_external_tools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: context_external_tools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE context_external_tools_id_seq OWNED BY context_external_tools.id;


--
-- Name: context_message_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE context_message_participants (
    id bigint NOT NULL,
    user_id bigint,
    context_message_id bigint,
    participation_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: context_message_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE context_message_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: context_message_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE context_message_participants_id_seq OWNED BY context_message_participants.id;


--
-- Name: context_module_progressions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE context_module_progressions (
    id bigint NOT NULL,
    context_module_id bigint,
    user_id bigint,
    requirements_met text,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    collapsed boolean,
    current_position integer,
    completed_at timestamp without time zone,
    current boolean,
    lock_version integer DEFAULT 0 NOT NULL,
    evaluated_at timestamp without time zone
);


--
-- Name: context_module_progressions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE context_module_progressions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: context_module_progressions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE context_module_progressions_id_seq OWNED BY context_module_progressions.id;


--
-- Name: context_modules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE context_modules (
    id bigint NOT NULL,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    name text,
    "position" integer,
    prerequisites text,
    completion_requirements text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    workflow_state character varying(255) DEFAULT 'active'::character varying NOT NULL,
    deleted_at timestamp without time zone,
    unlock_at timestamp without time zone,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    migration_id character varying(255),
    require_sequential_progress boolean,
    cloned_item_id bigint,
    completion_events text
);


--
-- Name: context_modules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE context_modules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: context_modules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE context_modules_id_seq OWNED BY context_modules.id;


--
-- Name: conversation_batches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE conversation_batches (
    id bigint NOT NULL,
    workflow_state character varying(255) NOT NULL,
    user_id bigint NOT NULL,
    recipient_ids text,
    root_conversation_message_id bigint NOT NULL,
    conversation_message_ids text,
    tags text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    context_type character varying(255),
    context_id bigint,
    subject character varying(255),
    "group" boolean,
    generate_user_note boolean
);


--
-- Name: conversation_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE conversation_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conversation_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE conversation_batches_id_seq OWNED BY conversation_batches.id;


--
-- Name: conversation_message_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE conversation_message_participants (
    id bigint NOT NULL,
    conversation_message_id bigint,
    conversation_participant_id bigint,
    tags text,
    user_id bigint,
    workflow_state character varying(255)
);


--
-- Name: conversation_message_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE conversation_message_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conversation_message_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE conversation_message_participants_id_seq OWNED BY conversation_message_participants.id;


--
-- Name: conversation_messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE conversation_messages (
    id bigint NOT NULL,
    conversation_id bigint,
    author_id bigint,
    created_at timestamp without time zone,
    generated boolean,
    body text,
    forwarded_message_ids text,
    media_comment_id character varying(255),
    media_comment_type character varying(255),
    context_id bigint,
    context_type character varying(255),
    asset_id bigint,
    asset_type character varying(255),
    attachment_ids text,
    has_attachments boolean,
    has_media_objects boolean
);


--
-- Name: conversation_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE conversation_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conversation_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE conversation_messages_id_seq OWNED BY conversation_messages.id;


--
-- Name: conversation_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE conversation_participants (
    id bigint NOT NULL,
    conversation_id bigint NOT NULL,
    user_id bigint NOT NULL,
    last_message_at timestamp without time zone,
    subscribed boolean DEFAULT true,
    workflow_state character varying(255) NOT NULL,
    last_authored_at timestamp without time zone,
    has_attachments boolean DEFAULT false NOT NULL,
    has_media_objects boolean DEFAULT false NOT NULL,
    message_count integer DEFAULT 0,
    label character varying(255),
    tags text,
    visible_last_authored_at timestamp without time zone,
    root_account_ids text,
    private_hash character varying(255)
);


--
-- Name: conversation_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE conversation_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conversation_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE conversation_participants_id_seq OWNED BY conversation_participants.id;


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE conversations (
    id bigint NOT NULL,
    private_hash character varying(255),
    has_attachments boolean DEFAULT false NOT NULL,
    has_media_objects boolean DEFAULT false NOT NULL,
    tags text,
    root_account_ids text,
    subject character varying(255),
    context_type character varying(255),
    context_id bigint
);


--
-- Name: conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE conversations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE conversations_id_seq OWNED BY conversations.id;


--
-- Name: course_account_associations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE course_account_associations (
    id bigint NOT NULL,
    course_id bigint NOT NULL,
    account_id bigint NOT NULL,
    depth integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    course_section_id bigint
);


--
-- Name: course_account_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_account_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_account_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_account_associations_id_seq OWNED BY course_account_associations.id;


--
-- Name: course_imports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE course_imports (
    id bigint NOT NULL,
    course_id bigint NOT NULL,
    source_id bigint,
    added_item_codes text,
    log text,
    workflow_state character varying(255) NOT NULL,
    import_type character varying(255) NOT NULL,
    progress integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    parameters text
);


--
-- Name: course_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_imports_id_seq OWNED BY course_imports.id;


--
-- Name: course_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE course_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: course_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE course_sections_id_seq OWNED BY course_sections.id;


--
-- Name: courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE courses_id_seq OWNED BY courses.id;


--
-- Name: crocodoc_documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE crocodoc_documents (
    id bigint NOT NULL,
    uuid character varying(255),
    process_state character varying(255),
    attachment_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: crocodoc_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE crocodoc_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crocodoc_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE crocodoc_documents_id_seq OWNED BY crocodoc_documents.id;


--
-- Name: custom_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE custom_data (
    id bigint NOT NULL,
    data text,
    namespace character varying(255),
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: custom_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE custom_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE custom_data_id_seq OWNED BY custom_data.id;


--
-- Name: custom_gradebook_column_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE custom_gradebook_column_data (
    id bigint NOT NULL,
    content character varying(255) NOT NULL,
    user_id bigint NOT NULL,
    custom_gradebook_column_id bigint NOT NULL
);


--
-- Name: custom_gradebook_column_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE custom_gradebook_column_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_gradebook_column_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE custom_gradebook_column_data_id_seq OWNED BY custom_gradebook_column_data.id;


--
-- Name: custom_gradebook_columns; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE custom_gradebook_columns (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    "position" integer NOT NULL,
    workflow_state character varying(255) DEFAULT 'active'::character varying NOT NULL,
    course_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    teacher_notes boolean DEFAULT false NOT NULL
);


--
-- Name: custom_gradebook_columns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE custom_gradebook_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: custom_gradebook_columns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE custom_gradebook_columns_id_seq OWNED BY custom_gradebook_columns.id;


--
-- Name: data_exports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE data_exports (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: data_exports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE data_exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_exports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE data_exports_id_seq OWNED BY data_exports.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id bigint NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    queue character varying(255),
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tag character varying(255),
    max_attempts integer,
    strand character varying(255),
    next_in_strand boolean DEFAULT true NOT NULL,
    source character varying(255)
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: delayed_messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_messages (
    id bigint NOT NULL,
    notification_id bigint,
    notification_policy_id bigint,
    context_id bigint,
    context_type character varying(255),
    communication_channel_id bigint,
    frequency character varying(255),
    workflow_state character varying(255),
    batched_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    send_at timestamp without time zone,
    link character varying(255),
    name_of_topic text,
    summary text,
    root_account_id bigint
);


--
-- Name: delayed_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_messages_id_seq OWNED BY delayed_messages.id;


--
-- Name: delayed_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_notifications (
    id bigint NOT NULL,
    notification_id bigint NOT NULL,
    asset_id bigint NOT NULL,
    asset_type character varying(255) NOT NULL,
    recipient_keys text,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    asset_context_type character varying(255),
    asset_context_id bigint
);


--
-- Name: delayed_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_notifications_id_seq OWNED BY delayed_notifications.id;


--
-- Name: developer_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE developer_keys (
    id bigint NOT NULL,
    api_key character varying(255),
    email character varying(255),
    user_name character varying(255),
    account_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id bigint,
    name character varying(255),
    redirect_uri character varying(255),
    tool_id character varying(255),
    icon_url character varying(255),
    sns_arn character varying(255),
    trusted boolean
);


--
-- Name: developer_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE developer_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: developer_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE developer_keys_id_seq OWNED BY developer_keys.id;


--
-- Name: discussion_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE discussion_entries (
    id bigint NOT NULL,
    message text,
    discussion_topic_id bigint,
    user_id bigint,
    parent_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    attachment_id bigint,
    workflow_state character varying(255) DEFAULT 'active'::character varying,
    deleted_at timestamp without time zone,
    migration_id character varying(255),
    editor_id bigint,
    root_entry_id bigint,
    depth integer
);


--
-- Name: discussion_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE discussion_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discussion_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE discussion_entries_id_seq OWNED BY discussion_entries.id;


--
-- Name: discussion_entry_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE discussion_entry_participants (
    id bigint NOT NULL,
    discussion_entry_id bigint NOT NULL,
    user_id bigint NOT NULL,
    workflow_state character varying(255) NOT NULL,
    forced_read_state boolean
);


--
-- Name: discussion_entry_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE discussion_entry_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discussion_entry_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE discussion_entry_participants_id_seq OWNED BY discussion_entry_participants.id;


--
-- Name: discussion_topic_materialized_views; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE discussion_topic_materialized_views (
    discussion_topic_id bigint NOT NULL,
    json_structure character varying(10485760),
    participants_array character varying(10485760),
    entry_ids_array character varying(10485760),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    generation_started_at timestamp without time zone
);


--
-- Name: discussion_topic_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE discussion_topic_participants (
    id bigint NOT NULL,
    discussion_topic_id bigint NOT NULL,
    user_id bigint NOT NULL,
    unread_entry_count integer DEFAULT 0 NOT NULL,
    workflow_state character varying(255) NOT NULL,
    subscribed boolean
);


--
-- Name: discussion_topic_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE discussion_topic_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discussion_topic_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE discussion_topic_participants_id_seq OWNED BY discussion_topic_participants.id;


--
-- Name: discussion_topics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE discussion_topics (
    id bigint NOT NULL,
    title character varying(255),
    message text,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    type character varying(255),
    user_id bigint,
    workflow_state character varying(255) NOT NULL,
    last_reply_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    delayed_post_at timestamp without time zone,
    posted_at timestamp without time zone,
    assignment_id bigint,
    attachment_id bigint,
    deleted_at timestamp without time zone,
    root_topic_id bigint,
    could_be_locked boolean,
    cloned_item_id bigint,
    context_code character varying(255),
    "position" integer,
    migration_id character varying(255),
    old_assignment_id bigint,
    subtopics_refreshed_at timestamp without time zone,
    last_assignment_id bigint,
    external_feed_id bigint,
    editor_id bigint,
    podcast_enabled boolean,
    podcast_has_student_posts boolean,
    require_initial_post boolean,
    discussion_type character varying(255),
    lock_at timestamp without time zone,
    pinned boolean,
    locked boolean,
    group_category_id bigint
);


--
-- Name: discussion_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE discussion_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: discussion_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE discussion_topics_id_seq OWNED BY discussion_topics.id;


--
-- Name: enrollment_dates_overrides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE enrollment_dates_overrides (
    id bigint NOT NULL,
    enrollment_term_id bigint,
    enrollment_type character varying(255),
    context_id bigint,
    context_type character varying(255),
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: enrollment_dates_overrides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE enrollment_dates_overrides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enrollment_dates_overrides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE enrollment_dates_overrides_id_seq OWNED BY enrollment_dates_overrides.id;


--
-- Name: enrollment_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE enrollment_terms (
    id bigint NOT NULL,
    root_account_id bigint NOT NULL,
    name character varying(255),
    term_code character varying(255),
    sis_source_id character varying(255),
    sis_batch_id bigint,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    accepting_enrollments boolean,
    can_manually_enroll boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    workflow_state character varying(255) DEFAULT 'active'::character varying NOT NULL,
    stuck_sis_fields text,
    integration_id character varying(255)
);


--
-- Name: enrollment_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE enrollment_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enrollment_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE enrollment_terms_id_seq OWNED BY enrollment_terms.id;


--
-- Name: enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE enrollments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE enrollments_id_seq OWNED BY enrollments.id;


--
-- Name: eportfolio_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eportfolio_categories (
    id bigint NOT NULL,
    eportfolio_id bigint NOT NULL,
    name character varying(255),
    "position" integer,
    slug character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: eportfolio_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE eportfolio_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eportfolio_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE eportfolio_categories_id_seq OWNED BY eportfolio_categories.id;


--
-- Name: eportfolio_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eportfolio_entries (
    id bigint NOT NULL,
    eportfolio_id bigint NOT NULL,
    eportfolio_category_id bigint NOT NULL,
    "position" integer,
    name character varying(255),
    artifact_type integer,
    attachment_id bigint,
    allow_comments boolean,
    show_comments boolean,
    slug character varying(255),
    url character varying(255),
    content text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: eportfolio_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE eportfolio_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eportfolio_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE eportfolio_entries_id_seq OWNED BY eportfolio_entries.id;


--
-- Name: eportfolios; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE eportfolios (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255),
    public boolean,
    context_id bigint,
    context_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid character varying(255),
    workflow_state character varying(255) DEFAULT 'active'::character varying NOT NULL,
    deleted_at timestamp without time zone
);


--
-- Name: eportfolios_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE eportfolios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eportfolios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE eportfolios_id_seq OWNED BY eportfolios.id;


--
-- Name: error_reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE error_reports (
    id bigint NOT NULL,
    backtrace text,
    url text,
    message text,
    comments text,
    user_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    email character varying(255),
    during_tests boolean DEFAULT false,
    user_agent text,
    request_method character varying(255),
    http_env text,
    subject character varying(255),
    request_context_id character varying(255),
    account_id bigint,
    zendesk_ticket_id bigint,
    data text,
    category character varying(255)
);


--
-- Name: error_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE error_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: error_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE error_reports_id_seq OWNED BY error_reports.id;


--
-- Name: event_stream_failures; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE event_stream_failures (
    id bigint NOT NULL,
    operation character varying(255) NOT NULL,
    event_stream character varying(255) NOT NULL,
    record_id character varying(255) NOT NULL,
    payload text NOT NULL,
    exception text,
    backtrace text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: event_stream_failures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_stream_failures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_stream_failures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_stream_failures_id_seq OWNED BY event_stream_failures.id;


--
-- Name: external_feed_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE external_feed_entries (
    id bigint NOT NULL,
    user_id bigint,
    external_feed_id bigint NOT NULL,
    title character varying(255),
    message text,
    source_name character varying(255),
    source_url character varying(255),
    posted_at timestamp without time zone,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    workflow_state character varying(255) NOT NULL,
    url character varying(4096),
    author_name character varying(255),
    author_email character varying(255),
    author_url character varying(255),
    asset_id bigint,
    asset_type character varying(255),
    uuid character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: external_feed_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE external_feed_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_feed_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE external_feed_entries_id_seq OWNED BY external_feed_entries.id;


--
-- Name: external_feeds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE external_feeds (
    id bigint NOT NULL,
    user_id bigint,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    consecutive_failures integer,
    failures integer,
    refresh_at timestamp without time zone,
    title character varying(255),
    feed_type character varying(255),
    feed_purpose character varying(255),
    url character varying(255) NOT NULL,
    header_match character varying(255),
    body_match character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    verbosity character varying(255),
    migration_id character varying(255)
);


--
-- Name: external_feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE external_feeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_feeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE external_feeds_id_seq OWNED BY external_feeds.id;


--
-- Name: external_integration_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE external_integration_keys (
    id bigint NOT NULL,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    key_value character varying(255) NOT NULL,
    key_type character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: external_integration_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE external_integration_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: external_integration_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE external_integration_keys_id_seq OWNED BY external_integration_keys.id;


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE failed_jobs (
    id bigint NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler character varying(512000),
    last_error text,
    queue character varying(255),
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tag character varying(255),
    max_attempts integer,
    strand character varying(255),
    original_job_id bigint,
    source character varying(255)
);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE failed_jobs_id_seq OWNED BY failed_jobs.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites (
    id bigint NOT NULL,
    user_id bigint,
    context_id bigint,
    context_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_id_seq OWNED BY favorites.id;


--
-- Name: feature_flags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feature_flags (
    id bigint NOT NULL,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    feature character varying(255) NOT NULL,
    state character varying(255) DEFAULT 'allowed'::character varying NOT NULL,
    locking_account_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: feature_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feature_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feature_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feature_flags_id_seq OWNED BY feature_flags.id;


--
-- Name: folders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE folders (
    id bigint NOT NULL,
    name character varying(255),
    full_name text,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    parent_folder_id bigint,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    locked boolean,
    lock_at timestamp without time zone,
    unlock_at timestamp without time zone,
    last_lock_at timestamp without time zone,
    last_unlock_at timestamp without time zone,
    cloned_item_id bigint,
    "position" integer
);


--
-- Name: folders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE folders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: folders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE folders_id_seq OWNED BY folders.id;


--
-- Name: gradebook_uploads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gradebook_uploads (
    id bigint NOT NULL,
    context_id bigint,
    context_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: gradebook_uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gradebook_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gradebook_uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gradebook_uploads_id_seq OWNED BY gradebook_uploads.id;


--
-- Name: grading_period_grades; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE grading_period_grades (
    id bigint NOT NULL,
    enrollment_id bigint,
    grading_period_id bigint,
    current_grade double precision,
    final_grade double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: grading_period_grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE grading_period_grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grading_period_grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE grading_period_grades_id_seq OWNED BY grading_period_grades.id;


--
-- Name: grading_period_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE grading_period_groups (
    id bigint NOT NULL,
    course_id bigint,
    account_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: grading_period_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE grading_period_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grading_period_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE grading_period_groups_id_seq OWNED BY grading_period_groups.id;


--
-- Name: grading_periods; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE grading_periods (
    id bigint NOT NULL,
    weight double precision NOT NULL,
    start_date timestamp without time zone NOT NULL,
    end_date timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying(255),
    workflow_state character varying(255),
    grading_period_group_id bigint
);


--
-- Name: grading_periods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE grading_periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grading_periods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE grading_periods_id_seq OWNED BY grading_periods.id;


--
-- Name: grading_standards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE grading_standards (
    id bigint NOT NULL,
    title character varying(255),
    data text,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id bigint,
    usage_count integer,
    context_code character varying(255),
    workflow_state character varying(255) NOT NULL,
    migration_id character varying(255),
    version integer
);


--
-- Name: grading_standards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE grading_standards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grading_standards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE grading_standards_id_seq OWNED BY grading_standards.id;


--
-- Name: group_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_categories (
    id bigint NOT NULL,
    context_id bigint,
    context_type character varying(255),
    name character varying(255),
    role character varying(255),
    deleted_at timestamp without time zone,
    self_signup character varying(255),
    group_limit integer,
    auto_leader character varying(255)
);


--
-- Name: group_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_categories_id_seq OWNED BY group_categories.id;


--
-- Name: group_memberships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_memberships (
    id bigint NOT NULL,
    group_id bigint NOT NULL,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id bigint NOT NULL,
    uuid character varying(255),
    sis_batch_id bigint,
    moderator boolean
);


--
-- Name: group_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_memberships_id_seq OWNED BY group_memberships.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    id bigint NOT NULL,
    name character varying(255),
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    category character varying(255),
    max_membership integer,
    hashtag character varying(255),
    show_public_context_messages boolean,
    is_public boolean,
    account_id bigint NOT NULL,
    default_wiki_editing_roles character varying(255),
    wiki_id bigint,
    deleted_at timestamp without time zone,
    join_level character varying(255),
    default_view character varying(255) DEFAULT 'feed'::character varying,
    migration_id character varying(255),
    storage_quota bigint,
    uuid character varying(255),
    root_account_id bigint NOT NULL,
    sis_source_id character varying(255),
    sis_batch_id bigint,
    stuck_sis_fields text,
    group_category_id bigint,
    description text,
    avatar_attachment_id bigint,
    leader_id bigint
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: icl_individual_projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE icl_individual_projects (
    id bigint NOT NULL,
    course_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: icl_individual_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE icl_individual_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: icl_individual_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE icl_individual_projects_id_seq OWNED BY icl_individual_projects.id;


--
-- Name: icl_project_choices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE icl_project_choices (
    id bigint NOT NULL,
    user_id integer,
    icl_project_id integer,
    preference integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: icl_project_choices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE icl_project_choices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: icl_project_choices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE icl_project_choices_id_seq OWNED BY icl_project_choices.id;


--
-- Name: icl_projects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE icl_projects (
    id bigint NOT NULL,
    title character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    category integer,
    course_id integer
);


--
-- Name: icl_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE icl_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: icl_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE icl_projects_id_seq OWNED BY icl_projects.id;


--
-- Name: ignores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ignores (
    id bigint NOT NULL,
    asset_type character varying(255) NOT NULL,
    asset_id bigint NOT NULL,
    user_id bigint NOT NULL,
    purpose character varying(255) NOT NULL,
    permanent boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ignores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ignores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ignores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ignores_id_seq OWNED BY ignores.id;


--
-- Name: inbox_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inbox_items (
    id bigint NOT NULL,
    user_id bigint,
    sender_id bigint,
    asset_id bigint,
    subject character varying(255),
    body_teaser character varying(255),
    asset_type character varying(255),
    workflow_state character varying(255),
    sender boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    context_code character varying(255)
);


--
-- Name: inbox_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inbox_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inbox_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inbox_items_id_seq OWNED BY inbox_items.id;


--
-- Name: learning_outcome_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE learning_outcome_groups (
    id bigint NOT NULL,
    context_id bigint,
    context_type character varying(255),
    title character varying(255) NOT NULL,
    learning_outcome_group_id bigint,
    root_learning_outcome_group_id bigint,
    workflow_state character varying(255) NOT NULL,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    migration_id character varying(255),
    vendor_guid character varying(255),
    low_grade character varying(255),
    high_grade character varying(255)
);


--
-- Name: learning_outcome_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE learning_outcome_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: learning_outcome_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE learning_outcome_groups_id_seq OWNED BY learning_outcome_groups.id;


--
-- Name: learning_outcome_results; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE learning_outcome_results (
    id bigint NOT NULL,
    context_id bigint,
    context_type character varying(255),
    context_code character varying(255),
    association_id bigint,
    association_type character varying(255),
    content_tag_id bigint,
    learning_outcome_id bigint,
    mastery boolean,
    user_id bigint,
    score double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    attempt integer,
    possible double precision,
    comments character varying(255),
    original_score double precision,
    original_possible double precision,
    original_mastery boolean,
    artifact_id bigint,
    artifact_type character varying(255),
    assessed_at timestamp without time zone,
    title character varying(255),
    percent double precision,
    associated_asset_id bigint,
    associated_asset_type character varying(255),
    submitted_at timestamp without time zone
);


--
-- Name: learning_outcome_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE learning_outcome_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: learning_outcome_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE learning_outcome_results_id_seq OWNED BY learning_outcome_results.id;


--
-- Name: learning_outcomes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE learning_outcomes (
    id bigint NOT NULL,
    context_id bigint,
    context_type character varying(255),
    short_description character varying(255) NOT NULL,
    context_code character varying(255),
    description text,
    data text,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    migration_id character varying(255),
    vendor_guid character varying(255),
    low_grade character varying(255),
    high_grade character varying(255),
    display_name character varying(255),
    calculation_method character varying(255),
    calculation_int smallint
);


--
-- Name: learning_outcomes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE learning_outcomes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: learning_outcomes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE learning_outcomes_id_seq OWNED BY learning_outcomes.id;


--
-- Name: live_assessments_assessments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE live_assessments_assessments (
    id bigint NOT NULL,
    key character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: live_assessments_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE live_assessments_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: live_assessments_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE live_assessments_assessments_id_seq OWNED BY live_assessments_assessments.id;


--
-- Name: live_assessments_results; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE live_assessments_results (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    assessor_id bigint NOT NULL,
    assessment_id bigint NOT NULL,
    passed boolean NOT NULL,
    assessed_at timestamp without time zone NOT NULL
);


--
-- Name: live_assessments_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE live_assessments_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: live_assessments_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE live_assessments_results_id_seq OWNED BY live_assessments_results.id;


--
-- Name: live_assessments_submissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE live_assessments_submissions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    assessment_id bigint NOT NULL,
    possible double precision,
    score double precision,
    assessed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: live_assessments_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE live_assessments_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: live_assessments_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE live_assessments_submissions_id_seq OWNED BY live_assessments_submissions.id;


--
-- Name: lti_message_handlers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lti_message_handlers (
    id bigint NOT NULL,
    message_type character varying(255) NOT NULL,
    launch_path character varying(255) NOT NULL,
    capabilities text,
    parameters text,
    resource_handler_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lti_message_handlers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lti_message_handlers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lti_message_handlers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lti_message_handlers_id_seq OWNED BY lti_message_handlers.id;


--
-- Name: lti_product_families; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lti_product_families (
    id bigint NOT NULL,
    vendor_code character varying(255) NOT NULL,
    product_code character varying(255) NOT NULL,
    vendor_name character varying(255) NOT NULL,
    vendor_description text,
    website character varying(255),
    vendor_email character varying(255),
    root_account_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lti_product_families_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lti_product_families_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lti_product_families_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lti_product_families_id_seq OWNED BY lti_product_families.id;


--
-- Name: lti_resource_handlers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lti_resource_handlers (
    id bigint NOT NULL,
    resource_type_code character varying(255) NOT NULL,
    placements character varying(255),
    name character varying(255) NOT NULL,
    description text,
    icon_info text,
    tool_proxy_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lti_resource_handlers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lti_resource_handlers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lti_resource_handlers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lti_resource_handlers_id_seq OWNED BY lti_resource_handlers.id;


--
-- Name: lti_resource_placements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lti_resource_placements (
    id bigint NOT NULL,
    resource_handler_id bigint NOT NULL,
    placement character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lti_resource_placements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lti_resource_placements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lti_resource_placements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lti_resource_placements_id_seq OWNED BY lti_resource_placements.id;


--
-- Name: lti_tool_proxies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lti_tool_proxies (
    id bigint NOT NULL,
    shared_secret character varying(255) NOT NULL,
    guid character varying(255) NOT NULL,
    product_version character varying(255) NOT NULL,
    lti_version character varying(255) NOT NULL,
    product_family_id bigint NOT NULL,
    context_id bigint NOT NULL,
    workflow_state character varying(255) NOT NULL,
    raw_data text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    context_type character varying(255) DEFAULT 'Account'::character varying NOT NULL,
    name character varying(255),
    description character varying(255)
);


--
-- Name: lti_tool_proxies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lti_tool_proxies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lti_tool_proxies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lti_tool_proxies_id_seq OWNED BY lti_tool_proxies.id;


--
-- Name: lti_tool_proxy_bindings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lti_tool_proxy_bindings (
    id bigint NOT NULL,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    tool_proxy_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    enabled boolean DEFAULT true NOT NULL
);


--
-- Name: lti_tool_proxy_bindings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lti_tool_proxy_bindings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lti_tool_proxy_bindings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lti_tool_proxy_bindings_id_seq OWNED BY lti_tool_proxy_bindings.id;


--
-- Name: lti_tool_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lti_tool_settings (
    id bigint NOT NULL,
    tool_proxy_id bigint NOT NULL,
    context_id bigint,
    context_type character varying(255),
    resource_link_id text,
    custom text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: lti_tool_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lti_tool_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lti_tool_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lti_tool_settings_id_seq OWNED BY lti_tool_settings.id;


--
-- Name: media_objects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_objects (
    id bigint NOT NULL,
    user_id bigint,
    context_id bigint,
    context_type character varying(255),
    workflow_state character varying(255) NOT NULL,
    user_type character varying(255),
    title character varying(255),
    user_entered_title character varying(255),
    media_id character varying(255) NOT NULL,
    media_type character varying(255),
    duration integer,
    max_size integer,
    root_account_id bigint,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    attachment_id bigint,
    total_size integer,
    old_media_id character varying(255)
);


--
-- Name: media_objects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_objects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_objects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_objects_id_seq OWNED BY media_objects.id;


--
-- Name: media_tracks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_tracks (
    id bigint NOT NULL,
    user_id bigint,
    media_object_id bigint NOT NULL,
    kind character varying(255) DEFAULT 'subtitles'::character varying,
    locale character varying(255) DEFAULT 'en'::character varying,
    content text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: media_tracks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_tracks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_tracks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_tracks_id_seq OWNED BY media_tracks.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE messages (
    id bigint NOT NULL,
    "to" character varying(255),
    "from" character varying(255),
    cc character varying(255),
    bcc character varying(255),
    subject text,
    body text,
    delay_for integer DEFAULT 120,
    dispatch_at timestamp without time zone,
    sent_at timestamp without time zone,
    workflow_state character varying(255),
    transmission_errors text,
    is_bounced boolean,
    notification_id bigint,
    communication_channel_id bigint,
    context_id bigint,
    context_type character varying(255),
    asset_context_id bigint,
    asset_context_type character varying(255),
    user_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    notification_name character varying(255),
    url character varying(255),
    path_type character varying(255),
    from_name text,
    asset_context_code character varying(255),
    notification_category character varying(255),
    to_email boolean,
    html_body text,
    root_account_id bigint,
    reply_to_name character varying(255)
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: migration_issues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE migration_issues (
    id bigint NOT NULL,
    content_migration_id bigint NOT NULL,
    description text,
    workflow_state character varying(255) NOT NULL,
    fix_issue_html_url text,
    issue_type character varying(255) NOT NULL,
    error_report_id bigint,
    error_message text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: migration_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE migration_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migration_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE migration_issues_id_seq OWNED BY migration_issues.id;


--
-- Name: notification_policies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notification_policies (
    id bigint NOT NULL,
    notification_id bigint,
    communication_channel_id bigint NOT NULL,
    frequency character varying(255) DEFAULT 'immediately'::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: notification_policies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notification_policies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_policies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notification_policies_id_seq OWNED BY notification_policies.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id bigint NOT NULL,
    workflow_state character varying(255) NOT NULL,
    name character varying(255),
    subject character varying(255),
    category character varying(255),
    delay_for integer DEFAULT 120,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    main_link character varying(255)
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: oauth_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_requests (
    id bigint NOT NULL,
    token character varying(255),
    secret character varying(255),
    user_secret character varying(255),
    return_url character varying(4096),
    workflow_state character varying(255),
    user_id bigint,
    original_host_with_port character varying(255),
    service character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: oauth_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_requests_id_seq OWNED BY oauth_requests.id;


--
-- Name: page_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE page_comments (
    id bigint NOT NULL,
    message text,
    page_id bigint,
    page_type character varying(255),
    user_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: page_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE page_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE page_comments_id_seq OWNED BY page_comments.id;


--
-- Name: page_views; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE page_views (
    request_id character varying(255) NOT NULL,
    session_id character varying(255),
    user_id bigint NOT NULL,
    url text,
    context_id bigint,
    context_type character varying(255),
    asset_id bigint,
    asset_type character varying(255),
    controller character varying(255),
    action character varying(255),
    interaction_seconds double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    developer_key_id bigint,
    user_request boolean,
    render_time double precision,
    user_agent text,
    asset_user_access_id bigint,
    participated boolean,
    summarized boolean,
    account_id bigint,
    real_user_id bigint,
    http_method character varying(255),
    remote_ip character varying(255)
);


--
-- Name: plugin_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE plugin_settings (
    id bigint NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    settings text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    disabled boolean
);


--
-- Name: plugin_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE plugin_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plugin_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE plugin_settings_id_seq OWNED BY plugin_settings.id;


--
-- Name: polling_poll_choices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE polling_poll_choices (
    id bigint NOT NULL,
    text character varying(255),
    is_correct boolean DEFAULT false NOT NULL,
    poll_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "position" integer
);


--
-- Name: polling_poll_choices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE polling_poll_choices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: polling_poll_choices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE polling_poll_choices_id_seq OWNED BY polling_poll_choices.id;


--
-- Name: polling_poll_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE polling_poll_sessions (
    id bigint NOT NULL,
    is_published boolean DEFAULT false NOT NULL,
    has_public_results boolean DEFAULT false NOT NULL,
    course_id bigint NOT NULL,
    course_section_id bigint,
    poll_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: polling_poll_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE polling_poll_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: polling_poll_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE polling_poll_sessions_id_seq OWNED BY polling_poll_sessions.id;


--
-- Name: polling_poll_submissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE polling_poll_submissions (
    id bigint NOT NULL,
    poll_id bigint NOT NULL,
    poll_choice_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    poll_session_id bigint NOT NULL
);


--
-- Name: polling_poll_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE polling_poll_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: polling_poll_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE polling_poll_submissions_id_seq OWNED BY polling_poll_submissions.id;


--
-- Name: polling_polls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE polling_polls (
    id bigint NOT NULL,
    question character varying(255),
    description character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id bigint NOT NULL
);


--
-- Name: polling_polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE polling_polls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: polling_polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE polling_polls_id_seq OWNED BY polling_polls.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE profiles (
    id bigint NOT NULL,
    root_account_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    context_id bigint NOT NULL,
    title character varying(255),
    path character varying(255),
    description text,
    data text,
    visibility character varying(255),
    "position" integer
);


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;


--
-- Name: progresses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE progresses (
    id bigint NOT NULL,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    user_id bigint,
    tag character varying(255) NOT NULL,
    completion double precision,
    delayed_job_id character varying(255),
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    message text,
    cache_key_context character varying(255),
    results text
);


--
-- Name: progresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE progresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: progresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE progresses_id_seq OWNED BY progresses.id;


--
-- Name: project_courses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE project_courses (
    id bigint NOT NULL,
    icl_project_id integer,
    course_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: project_courses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE project_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: project_courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE project_courses_id_seq OWNED BY project_courses.id;


--
-- Name: pseudonyms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pseudonyms (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    account_id bigint NOT NULL,
    workflow_state character varying(255) NOT NULL,
    unique_id character varying(255) NOT NULL,
    crypted_password character varying(255) NOT NULL,
    password_salt character varying(255) NOT NULL,
    persistence_token character varying(255) NOT NULL,
    single_access_token character varying(255) NOT NULL,
    perishable_token character varying(255) NOT NULL,
    login_count integer DEFAULT 0 NOT NULL,
    failed_login_count integer DEFAULT 0 NOT NULL,
    last_request_at timestamp without time zone,
    last_login_at timestamp without time zone,
    current_login_at timestamp without time zone,
    last_login_ip character varying(255),
    current_login_ip character varying(255),
    reset_password_token character varying(255) DEFAULT ''::character varying NOT NULL,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    password_auto_generated boolean,
    deleted_at timestamp without time zone,
    sis_batch_id bigint,
    sis_user_id character varying(255),
    sis_ssha character varying(255),
    communication_channel_id bigint,
    login_path_to_ignore character varying(255),
    sis_communication_channel_id bigint,
    stuck_sis_fields text,
    integration_id character varying(255)
);


--
-- Name: pseudonyms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pseudonyms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pseudonyms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pseudonyms_id_seq OWNED BY pseudonyms.id;


--
-- Name: quiz_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_groups (
    id bigint NOT NULL,
    quiz_id bigint NOT NULL,
    name character varying(255),
    pick_count integer,
    question_points double precision,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    migration_id character varying(255),
    assessment_question_bank_id bigint
);


--
-- Name: quiz_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quiz_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quiz_groups_id_seq OWNED BY quiz_groups.id;


--
-- Name: quiz_question_regrades; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_question_regrades (
    id bigint NOT NULL,
    quiz_regrade_id bigint NOT NULL,
    quiz_question_id bigint NOT NULL,
    regrade_option character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quiz_question_regrades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quiz_question_regrades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_question_regrades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quiz_question_regrades_id_seq OWNED BY quiz_question_regrades.id;


--
-- Name: quiz_questions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_questions (
    id bigint NOT NULL,
    quiz_id bigint,
    quiz_group_id bigint,
    assessment_question_id bigint,
    question_data text,
    assessment_question_version integer,
    "position" integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    migration_id character varying(255),
    workflow_state character varying(255)
);


--
-- Name: quiz_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quiz_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quiz_questions_id_seq OWNED BY quiz_questions.id;


--
-- Name: quiz_regrade_runs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_regrade_runs (
    id bigint NOT NULL,
    quiz_regrade_id bigint NOT NULL,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quiz_regrade_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quiz_regrade_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_regrade_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quiz_regrade_runs_id_seq OWNED BY quiz_regrade_runs.id;


--
-- Name: quiz_regrades; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_regrades (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    quiz_id bigint NOT NULL,
    quiz_version integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: quiz_regrades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quiz_regrades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_regrades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quiz_regrades_id_seq OWNED BY quiz_regrades.id;


--
-- Name: quiz_statistics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_statistics (
    id bigint NOT NULL,
    quiz_id bigint,
    includes_all_versions boolean,
    anonymous boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    report_type character varying(255)
);


--
-- Name: quiz_statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quiz_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_statistics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quiz_statistics_id_seq OWNED BY quiz_statistics.id;


--
-- Name: quizzes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quizzes (
    id bigint NOT NULL,
    title character varying(255),
    description text,
    quiz_data text,
    points_possible double precision,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    assignment_id bigint,
    workflow_state character varying(255) NOT NULL,
    shuffle_answers boolean,
    show_correct_answers boolean,
    time_limit integer,
    allowed_attempts integer,
    scoring_policy character varying(255),
    quiz_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    lock_at timestamp without time zone,
    unlock_at timestamp without time zone,
    deleted_at timestamp without time zone,
    could_be_locked boolean,
    cloned_item_id bigint,
    access_code character varying(255),
    migration_id character varying(255),
    unpublished_question_count integer DEFAULT 0,
    due_at timestamp without time zone,
    question_count integer,
    last_assignment_id bigint,
    published_at timestamp without time zone,
    last_edited_at timestamp without time zone,
    anonymous_submissions boolean,
    assignment_group_id bigint,
    hide_results character varying(255),
    ip_filter character varying(255),
    require_lockdown_browser boolean,
    require_lockdown_browser_for_results boolean,
    one_question_at_a_time boolean,
    cant_go_back boolean,
    show_correct_answers_at timestamp without time zone,
    hide_correct_answers_at timestamp without time zone,
    require_lockdown_browser_monitor boolean,
    lockdown_browser_monitor_data text,
    only_visible_to_overrides boolean,
    one_time_results boolean,
    show_correct_answers_last_attempt boolean
);


--
-- Name: quiz_student_visibilities; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW quiz_student_visibilities AS
 SELECT DISTINCT q.id AS quiz_id,
    e.user_id,
    c.id AS course_id
   FROM ((((((quizzes q
     JOIN courses c ON (((q.context_id = c.id) AND ((q.context_type)::text = 'Course'::text))))
     JOIN enrollments e ON ((((e.course_id = c.id) AND ((e.type)::text = ANY ((ARRAY['StudentEnrollment'::character varying, 'StudentViewEnrollment'::character varying])::text[]))) AND ((e.workflow_state)::text <> 'deleted'::text))))
     JOIN course_sections cs ON (((cs.course_id = c.id) AND (e.course_section_id = cs.id))))
     LEFT JOIN assignment_overrides ao ON (((((ao.quiz_id = q.id) AND ((ao.workflow_state)::text = 'active'::text)) AND ((ao.set_type)::text = 'CourseSection'::text)) AND (ao.set_id = cs.id))))
     LEFT JOIN assignments a ON ((((a.context_id = q.context_id) AND ((a.submission_types)::text ~~ 'online_quiz'::text)) AND (a.id = q.assignment_id))))
     LEFT JOIN submissions s ON ((((s.user_id = e.user_id) AND (s.assignment_id = a.id)) AND (s.score IS NOT NULL))))
  WHERE (((q.workflow_state)::text <> ALL ((ARRAY['deleted'::character varying, 'unpublished'::character varying])::text[])) AND (((q.only_visible_to_overrides = true) AND ((ao.id IS NOT NULL) OR (s.id IS NOT NULL))) OR (COALESCE(q.only_visible_to_overrides, false) = false)));


--
-- Name: quiz_submission_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_submission_events (
    id bigint NOT NULL,
    attempt integer NOT NULL,
    event_type character varying(255) NOT NULL,
    quiz_submission_id bigint NOT NULL,
    event_data text,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: quiz_submission_events_2014_11; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_submission_events_2014_11 (
    CONSTRAINT quiz_submission_events_2014_11_created_at_check CHECK (((created_at >= '2014-11-01 00:00:00'::timestamp without time zone) AND (created_at < '2014-12-01 00:00:00'::timestamp without time zone)))
)
INHERITS (quiz_submission_events);


--
-- Name: quiz_submission_events_2014_12; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_submission_events_2014_12 (
    CONSTRAINT quiz_submission_events_2014_12_created_at_check CHECK (((created_at >= '2014-12-01 00:00:00'::timestamp without time zone) AND (created_at < '2015-01-01 00:00:00'::timestamp without time zone)))
)
INHERITS (quiz_submission_events);


--
-- Name: quiz_submission_events_2015_1; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_submission_events_2015_1 (
    CONSTRAINT quiz_submission_events_2015_1_created_at_check CHECK (((created_at >= '2015-01-01 00:00:00'::timestamp without time zone) AND (created_at < '2015-02-01 00:00:00'::timestamp without time zone)))
)
INHERITS (quiz_submission_events);


--
-- Name: quiz_submission_events_2015_2; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_submission_events_2015_2 (
    CONSTRAINT quiz_submission_events_2015_2_created_at_check CHECK (((created_at >= '2015-02-01 00:00:00'::timestamp without time zone) AND (created_at < '2015-03-01 00:00:00'::timestamp without time zone)))
)
INHERITS (quiz_submission_events);


--
-- Name: quiz_submission_events_2015_3; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_submission_events_2015_3 (
    CONSTRAINT quiz_submission_events_2015_3_created_at_check CHECK (((created_at >= '2015-03-01 00:00:00'::timestamp without time zone) AND (created_at < '2015-04-01 00:00:00'::timestamp without time zone)))
)
INHERITS (quiz_submission_events);


--
-- Name: quiz_submission_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quiz_submission_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_submission_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quiz_submission_events_id_seq OWNED BY quiz_submission_events.id;


--
-- Name: quiz_submission_snapshots; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_submission_snapshots (
    id bigint NOT NULL,
    quiz_submission_id bigint,
    attempt integer,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: quiz_submission_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quiz_submission_snapshots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_submission_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quiz_submission_snapshots_id_seq OWNED BY quiz_submission_snapshots.id;


--
-- Name: quiz_submissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE quiz_submissions (
    id bigint NOT NULL,
    quiz_id bigint NOT NULL,
    quiz_version integer,
    user_id bigint,
    submission_data text,
    submission_id bigint,
    score double precision,
    kept_score double precision,
    quiz_data text,
    started_at timestamp without time zone,
    end_at timestamp without time zone,
    finished_at timestamp without time zone,
    attempt integer,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    fudge_points double precision DEFAULT 0,
    quiz_points_possible double precision,
    extra_attempts integer,
    temporary_user_code character varying(255),
    extra_time integer,
    manually_unlocked boolean,
    manually_scored boolean,
    validation_token character varying(255),
    score_before_regrade double precision,
    was_preview boolean,
    has_seen_results boolean,
    question_references_fixed boolean
);


--
-- Name: quiz_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quiz_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quiz_submissions_id_seq OWNED BY quiz_submissions.id;


--
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE quizzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE quizzes_id_seq OWNED BY quizzes.id;


--
-- Name: report_snapshots; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE report_snapshots (
    id bigint NOT NULL,
    report_type character varying(255),
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    account_id bigint
);


--
-- Name: report_snapshots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE report_snapshots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE report_snapshots_id_seq OWNED BY report_snapshots.id;


--
-- Name: role_overrides; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE role_overrides (
    id bigint NOT NULL,
    permission character varying(255),
    enabled boolean,
    locked boolean,
    context_id bigint,
    context_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    applies_to_self boolean DEFAULT true NOT NULL,
    applies_to_descendants boolean DEFAULT true NOT NULL,
    role_id bigint NOT NULL
);


--
-- Name: role_overrides_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE role_overrides_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_overrides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE role_overrides_id_seq OWNED BY role_overrides.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    base_role_type character varying(255) NOT NULL,
    account_id bigint,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    root_account_id bigint
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: rubric_assessments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rubric_assessments (
    id bigint NOT NULL,
    user_id bigint,
    rubric_id bigint NOT NULL,
    rubric_association_id bigint,
    score double precision,
    data text,
    comments text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    artifact_id bigint NOT NULL,
    artifact_type character varying(255) NOT NULL,
    assessment_type character varying(255) NOT NULL,
    assessor_id bigint,
    artifact_attempt integer
);


--
-- Name: rubric_assessments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rubric_assessments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rubric_assessments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rubric_assessments_id_seq OWNED BY rubric_assessments.id;


--
-- Name: rubric_associations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rubric_associations (
    id bigint NOT NULL,
    rubric_id bigint NOT NULL,
    association_id bigint NOT NULL,
    association_type character varying(255) NOT NULL,
    use_for_grading boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying(255),
    description text,
    summary_data text,
    purpose character varying(255) NOT NULL,
    url character varying(255),
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    hide_score_total boolean,
    bookmarked boolean DEFAULT true,
    context_code character varying(255)
);


--
-- Name: rubric_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rubric_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rubric_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rubric_associations_id_seq OWNED BY rubric_associations.id;


--
-- Name: rubrics; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rubrics (
    id bigint NOT NULL,
    user_id bigint,
    rubric_id bigint,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    data text,
    points_possible double precision,
    title character varying(255),
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    reusable boolean DEFAULT false,
    public boolean DEFAULT false,
    read_only boolean DEFAULT false,
    association_count integer DEFAULT 0,
    free_form_criterion_comments boolean,
    context_code character varying(255),
    migration_id character varying(255),
    hide_score_total boolean,
    workflow_state character varying(255) DEFAULT 'active'::character varying NOT NULL
);


--
-- Name: rubrics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rubrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rubrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rubrics_id_seq OWNED BY rubrics.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: scribd_mime_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scribd_mime_types (
    id bigint NOT NULL,
    extension character varying(255),
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: scribd_mime_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scribd_mime_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scribd_mime_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scribd_mime_types_id_seq OWNED BY scribd_mime_types.id;


--
-- Name: session_persistence_tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE session_persistence_tokens (
    id bigint NOT NULL,
    token_salt character varying(255) NOT NULL,
    crypted_token character varying(255) NOT NULL,
    pseudonym_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: session_persistence_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE session_persistence_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: session_persistence_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE session_persistence_tokens_id_seq OWNED BY session_persistence_tokens.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sessions (
    id bigint NOT NULL,
    session_id character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sessions_id_seq OWNED BY sessions.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id bigint NOT NULL,
    name character varying(255),
    value text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: sis_batches; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sis_batches (
    id bigint NOT NULL,
    account_id bigint NOT NULL,
    batch_id character varying(255),
    ended_at timestamp without time zone,
    errored_attempts integer,
    workflow_state character varying(255) NOT NULL,
    data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    attachment_id bigint,
    progress integer,
    processing_errors text,
    processing_warnings text,
    batch_mode boolean,
    batch_mode_term_id bigint,
    options text,
    user_id bigint
);


--
-- Name: sis_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sis_batches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sis_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sis_batches_id_seq OWNED BY sis_batches.id;


--
-- Name: sis_post_grades_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sis_post_grades_statuses (
    id bigint NOT NULL,
    course_id bigint NOT NULL,
    course_section_id bigint,
    user_id bigint,
    status character varying(255) NOT NULL,
    message character varying(255) NOT NULL,
    grades_posted_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sis_post_grades_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sis_post_grades_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sis_post_grades_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sis_post_grades_statuses_id_seq OWNED BY sis_post_grades_statuses.id;


--
-- Name: stories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stories (
    id bigint NOT NULL,
    text character varying(255)
);


--
-- Name: stories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stories_id_seq OWNED BY stories.id;


--
-- Name: stream_item_instances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stream_item_instances (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    stream_item_id bigint NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    workflow_state character varying(255),
    context_type character varying(255),
    context_id bigint
);


--
-- Name: stream_item_instances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stream_item_instances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stream_item_instances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stream_item_instances_id_seq OWNED BY stream_item_instances.id;


--
-- Name: stream_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stream_items (
    id bigint NOT NULL,
    data text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    context_type character varying(255),
    context_id bigint,
    asset_type character varying(255) NOT NULL,
    asset_id bigint
);


--
-- Name: stream_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stream_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stream_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stream_items_id_seq OWNED BY stream_items.id;


--
-- Name: submission_comment_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE submission_comment_participants (
    id bigint NOT NULL,
    submission_comment_id bigint,
    user_id bigint,
    participation_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: submission_comment_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE submission_comment_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submission_comment_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE submission_comment_participants_id_seq OWNED BY submission_comment_participants.id;


--
-- Name: submission_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE submission_comments (
    id bigint NOT NULL,
    comment text,
    submission_id bigint,
    recipient_id bigint,
    author_id bigint,
    author_name character varying(255),
    group_comment_id character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    attachment_ids text,
    assessment_request_id bigint,
    media_comment_id character varying(255),
    media_comment_type character varying(255),
    context_id bigint,
    context_type character varying(255),
    cached_attachments text,
    anonymous boolean,
    teacher_only_comment boolean DEFAULT false,
    hidden boolean DEFAULT false
);


--
-- Name: submission_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE submission_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submission_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE submission_comments_id_seq OWNED BY submission_comments.id;


--
-- Name: submission_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE submission_versions (
    id bigint NOT NULL,
    context_id bigint,
    context_type character varying(255),
    version_id bigint,
    user_id bigint,
    assignment_id bigint
);


--
-- Name: submission_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE submission_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submission_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE submission_versions_id_seq OWNED BY submission_versions.id;


--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE submissions_id_seq OWNED BY submissions.id;


--
-- Name: switchman_shards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE switchman_shards (
    id bigint NOT NULL,
    name character varying(255),
    database_server_id character varying(255),
    "default" boolean DEFAULT false NOT NULL,
    settings text
);


--
-- Name: switchman_shards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE switchman_shards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: switchman_shards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE switchman_shards_id_seq OWNED BY switchman_shards.id;


--
-- Name: thumbnails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE thumbnails (
    id bigint NOT NULL,
    parent_id bigint,
    content_type character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    thumbnail character varying(255),
    size integer NOT NULL,
    width integer,
    height integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid character varying(255),
    namespace character varying(255)
);


--
-- Name: thumbnails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE thumbnails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: thumbnails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE thumbnails_id_seq OWNED BY thumbnails.id;


--
-- Name: usage_rights; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE usage_rights (
    id bigint NOT NULL,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    use_justification character varying(255) NOT NULL,
    license character varying(255) NOT NULL,
    legal_copyright text
);


--
-- Name: usage_rights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE usage_rights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usage_rights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE usage_rights_id_seq OWNED BY usage_rights.id;


--
-- Name: user_account_associations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_account_associations (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    account_id bigint NOT NULL,
    depth integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_account_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_account_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_account_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_account_associations_id_seq OWNED BY user_account_associations.id;


--
-- Name: user_notes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_notes (
    id bigint NOT NULL,
    user_id bigint,
    note text,
    title character varying(255),
    created_by_id bigint,
    workflow_state character varying(255) DEFAULT 'active'::character varying NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: user_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_notes_id_seq OWNED BY user_notes.id;


--
-- Name: user_observers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_observers (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    observer_id bigint NOT NULL
);


--
-- Name: user_observers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_observers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_observers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_observers_id_seq OWNED BY user_observers.id;


--
-- Name: user_profile_links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_profile_links (
    id bigint NOT NULL,
    url character varying(4096),
    title character varying(255),
    user_profile_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_profile_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_profile_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_profile_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_profile_links_id_seq OWNED BY user_profile_links.id;


--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_profiles (
    id bigint NOT NULL,
    bio text,
    title character varying(255),
    user_id bigint
);


--
-- Name: user_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_profiles_id_seq OWNED BY user_profiles.id;


--
-- Name: user_services; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_services (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token character varying(255),
    secret character varying(255),
    protocol character varying(255),
    service character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    service_user_url character varying(255),
    service_user_id character varying(255) NOT NULL,
    service_user_name character varying(255),
    service_domain character varying(255),
    crypted_password character varying(255),
    password_salt character varying(255),
    type character varying(255),
    workflow_state character varying(255) NOT NULL,
    last_result_id character varying(255),
    refresh_at timestamp without time zone,
    visible boolean
);


--
-- Name: user_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_services_id_seq OWNED BY user_services.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id bigint NOT NULL,
    name character varying(255),
    sortable_name character varying(255),
    workflow_state character varying(255) NOT NULL,
    merge_to integer,
    time_zone character varying(255),
    uuid character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    visibility character varying(255),
    avatar_image_url character varying(255),
    avatar_image_source character varying(255),
    avatar_image_updated_at timestamp without time zone,
    phone character varying(255),
    school_name character varying(255),
    school_position character varying(255),
    short_name character varying(255),
    deleted_at timestamp without time zone,
    show_user_services boolean DEFAULT true,
    gender character varying(255),
    page_views_count integer DEFAULT 0,
    unread_inbox_items_count integer,
    reminder_time_for_due_dates integer DEFAULT 172800,
    reminder_time_for_grading integer DEFAULT 0,
    storage_quota bigint,
    visible_inbox_types character varying(255),
    last_user_note timestamp without time zone,
    subscribe_to_emails boolean,
    features_used text,
    preferences text,
    avatar_state character varying(255),
    locale character varying(255),
    browser_locale character varying(255),
    unread_conversations_count integer DEFAULT 0,
    stuck_sis_fields text,
    public boolean,
    birthdate timestamp without time zone,
    otp_secret_key_enc character varying(255),
    otp_secret_key_salt character varying(255),
    otp_communication_channel_id bigint,
    initial_enrollment_type character varying(255),
    crocodoc_id integer,
    last_logged_out timestamp without time zone,
    lti_context_id character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id bigint NOT NULL,
    versionable_id bigint,
    versionable_type character varying(255),
    number integer,
    yaml text,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: web_conference_participants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_conference_participants (
    id bigint NOT NULL,
    user_id bigint,
    web_conference_id bigint,
    participation_type character varying(255),
    workflow_state character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: web_conference_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_conference_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_conference_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_conference_participants_id_seq OWNED BY web_conference_participants.id;


--
-- Name: web_conferences; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_conferences (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    conference_type character varying(255) NOT NULL,
    conference_key character varying(255),
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    user_ids character varying(255),
    added_user_ids character varying(255),
    user_id bigint NOT NULL,
    started_at timestamp without time zone,
    description text,
    duration double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    uuid character varying(255),
    invited_user_ids character varying(255),
    ended_at timestamp without time zone,
    start_at timestamp without time zone,
    end_at timestamp without time zone,
    context_code character varying(255),
    type character varying(255),
    settings text
);


--
-- Name: web_conferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_conferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_conferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_conferences_id_seq OWNED BY web_conferences.id;


--
-- Name: wiki_pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wiki_pages (
    id bigint NOT NULL,
    wiki_id bigint NOT NULL,
    title character varying(255),
    body text,
    workflow_state character varying(255) NOT NULL,
    recent_editors character varying(255),
    user_id bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    url text,
    delayed_post_at timestamp without time zone,
    protected_editing boolean DEFAULT false,
    editing_roles character varying(255),
    view_count integer DEFAULT 0,
    revised_at timestamp without time zone,
    could_be_locked boolean,
    cloned_item_id bigint,
    migration_id character varying(255),
    wiki_page_comments_count integer
);


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wiki_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wiki_pages_id_seq OWNED BY wiki_pages.id;


--
-- Name: wikis; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wikis (
    id bigint NOT NULL,
    title character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    front_page_url text,
    has_no_front_page boolean
);


--
-- Name: wikis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wikis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wikis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wikis_id_seq OWNED BY wikis.id;


--
-- Name: zip_file_imports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zip_file_imports (
    id bigint NOT NULL,
    workflow_state character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    context_id bigint NOT NULL,
    context_type character varying(255) NOT NULL,
    attachment_id bigint,
    folder_id bigint,
    progress double precision,
    data text
);


--
-- Name: zip_file_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE zip_file_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: zip_file_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE zip_file_imports_id_seq OWNED BY zip_file_imports.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY abstract_courses ALTER COLUMN id SET DEFAULT nextval('abstract_courses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY access_tokens ALTER COLUMN id SET DEFAULT nextval('access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_authorization_configs ALTER COLUMN id SET DEFAULT nextval('account_authorization_configs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_notification_roles ALTER COLUMN id SET DEFAULT nextval('account_notification_roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_notifications ALTER COLUMN id SET DEFAULT nextval('account_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_reports ALTER COLUMN id SET DEFAULT nextval('account_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_users ALTER COLUMN id SET DEFAULT nextval('account_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY alert_criteria ALTER COLUMN id SET DEFAULT nextval('alert_criteria_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY alerts ALTER COLUMN id SET DEFAULT nextval('alerts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY appointment_group_contexts ALTER COLUMN id SET DEFAULT nextval('appointment_group_contexts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY appointment_group_sub_contexts ALTER COLUMN id SET DEFAULT nextval('appointment_group_sub_contexts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY appointment_groups ALTER COLUMN id SET DEFAULT nextval('appointment_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessment_question_bank_users ALTER COLUMN id SET DEFAULT nextval('assessment_question_bank_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessment_question_banks ALTER COLUMN id SET DEFAULT nextval('assessment_question_banks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessment_questions ALTER COLUMN id SET DEFAULT nextval('assessment_questions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessment_requests ALTER COLUMN id SET DEFAULT nextval('assessment_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY asset_user_accesses ALTER COLUMN id SET DEFAULT nextval('asset_user_accesses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignment_groups ALTER COLUMN id SET DEFAULT nextval('assignment_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignment_override_students ALTER COLUMN id SET DEFAULT nextval('assignment_override_students_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignment_overrides ALTER COLUMN id SET DEFAULT nextval('assignment_overrides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments ALTER COLUMN id SET DEFAULT nextval('assignments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachment_associations ALTER COLUMN id SET DEFAULT nextval('attachment_associations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments ALTER COLUMN id SET DEFAULT nextval('attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorization_codes ALTER COLUMN id SET DEFAULT nextval('authorization_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY calendar_events ALTER COLUMN id SET DEFAULT nextval('calendar_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY canvadocs ALTER COLUMN id SET DEFAULT nextval('canvadocs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cloned_items ALTER COLUMN id SET DEFAULT nextval('cloned_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collaborations ALTER COLUMN id SET DEFAULT nextval('collaborations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY collaborators ALTER COLUMN id SET DEFAULT nextval('collaborators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY communication_channels ALTER COLUMN id SET DEFAULT nextval('communication_channels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_exports ALTER COLUMN id SET DEFAULT nextval('content_exports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_migrations ALTER COLUMN id SET DEFAULT nextval('content_migrations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_participation_counts ALTER COLUMN id SET DEFAULT nextval('content_participation_counts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_participations ALTER COLUMN id SET DEFAULT nextval('content_participations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_tags ALTER COLUMN id SET DEFAULT nextval('content_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY context_external_tool_placements ALTER COLUMN id SET DEFAULT nextval('context_external_tool_placements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY context_external_tools ALTER COLUMN id SET DEFAULT nextval('context_external_tools_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY context_message_participants ALTER COLUMN id SET DEFAULT nextval('context_message_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY context_module_progressions ALTER COLUMN id SET DEFAULT nextval('context_module_progressions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY context_modules ALTER COLUMN id SET DEFAULT nextval('context_modules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY conversation_batches ALTER COLUMN id SET DEFAULT nextval('conversation_batches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY conversation_message_participants ALTER COLUMN id SET DEFAULT nextval('conversation_message_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY conversation_messages ALTER COLUMN id SET DEFAULT nextval('conversation_messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY conversation_participants ALTER COLUMN id SET DEFAULT nextval('conversation_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY conversations ALTER COLUMN id SET DEFAULT nextval('conversations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_account_associations ALTER COLUMN id SET DEFAULT nextval('course_account_associations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_imports ALTER COLUMN id SET DEFAULT nextval('course_imports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_sections ALTER COLUMN id SET DEFAULT nextval('course_sections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses ALTER COLUMN id SET DEFAULT nextval('courses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY crocodoc_documents ALTER COLUMN id SET DEFAULT nextval('crocodoc_documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_data ALTER COLUMN id SET DEFAULT nextval('custom_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_gradebook_column_data ALTER COLUMN id SET DEFAULT nextval('custom_gradebook_column_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_gradebook_columns ALTER COLUMN id SET DEFAULT nextval('custom_gradebook_columns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY data_exports ALTER COLUMN id SET DEFAULT nextval('data_exports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_messages ALTER COLUMN id SET DEFAULT nextval('delayed_messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_notifications ALTER COLUMN id SET DEFAULT nextval('delayed_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY developer_keys ALTER COLUMN id SET DEFAULT nextval('developer_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_entries ALTER COLUMN id SET DEFAULT nextval('discussion_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_entry_participants ALTER COLUMN id SET DEFAULT nextval('discussion_entry_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topic_participants ALTER COLUMN id SET DEFAULT nextval('discussion_topic_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topics ALTER COLUMN id SET DEFAULT nextval('discussion_topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollment_dates_overrides ALTER COLUMN id SET DEFAULT nextval('enrollment_dates_overrides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollment_terms ALTER COLUMN id SET DEFAULT nextval('enrollment_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollments ALTER COLUMN id SET DEFAULT nextval('enrollments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY eportfolio_categories ALTER COLUMN id SET DEFAULT nextval('eportfolio_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY eportfolio_entries ALTER COLUMN id SET DEFAULT nextval('eportfolio_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY eportfolios ALTER COLUMN id SET DEFAULT nextval('eportfolios_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY error_reports ALTER COLUMN id SET DEFAULT nextval('error_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_stream_failures ALTER COLUMN id SET DEFAULT nextval('event_stream_failures_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY external_feed_entries ALTER COLUMN id SET DEFAULT nextval('external_feed_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY external_feeds ALTER COLUMN id SET DEFAULT nextval('external_feeds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY external_integration_keys ALTER COLUMN id SET DEFAULT nextval('external_integration_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY failed_jobs ALTER COLUMN id SET DEFAULT nextval('failed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feature_flags ALTER COLUMN id SET DEFAULT nextval('feature_flags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY folders ALTER COLUMN id SET DEFAULT nextval('folders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY gradebook_uploads ALTER COLUMN id SET DEFAULT nextval('gradebook_uploads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY grading_period_grades ALTER COLUMN id SET DEFAULT nextval('grading_period_grades_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY grading_period_groups ALTER COLUMN id SET DEFAULT nextval('grading_period_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY grading_periods ALTER COLUMN id SET DEFAULT nextval('grading_periods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY grading_standards ALTER COLUMN id SET DEFAULT nextval('grading_standards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_categories ALTER COLUMN id SET DEFAULT nextval('group_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_memberships ALTER COLUMN id SET DEFAULT nextval('group_memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY icl_individual_projects ALTER COLUMN id SET DEFAULT nextval('icl_individual_projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY icl_project_choices ALTER COLUMN id SET DEFAULT nextval('icl_project_choices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY icl_projects ALTER COLUMN id SET DEFAULT nextval('icl_projects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ignores ALTER COLUMN id SET DEFAULT nextval('ignores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inbox_items ALTER COLUMN id SET DEFAULT nextval('inbox_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY learning_outcome_groups ALTER COLUMN id SET DEFAULT nextval('learning_outcome_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY learning_outcome_results ALTER COLUMN id SET DEFAULT nextval('learning_outcome_results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY learning_outcomes ALTER COLUMN id SET DEFAULT nextval('learning_outcomes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY live_assessments_assessments ALTER COLUMN id SET DEFAULT nextval('live_assessments_assessments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY live_assessments_results ALTER COLUMN id SET DEFAULT nextval('live_assessments_results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY live_assessments_submissions ALTER COLUMN id SET DEFAULT nextval('live_assessments_submissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_message_handlers ALTER COLUMN id SET DEFAULT nextval('lti_message_handlers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_product_families ALTER COLUMN id SET DEFAULT nextval('lti_product_families_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_resource_handlers ALTER COLUMN id SET DEFAULT nextval('lti_resource_handlers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_resource_placements ALTER COLUMN id SET DEFAULT nextval('lti_resource_placements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_tool_proxies ALTER COLUMN id SET DEFAULT nextval('lti_tool_proxies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_tool_proxy_bindings ALTER COLUMN id SET DEFAULT nextval('lti_tool_proxy_bindings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_tool_settings ALTER COLUMN id SET DEFAULT nextval('lti_tool_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_objects ALTER COLUMN id SET DEFAULT nextval('media_objects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_tracks ALTER COLUMN id SET DEFAULT nextval('media_tracks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY migration_issues ALTER COLUMN id SET DEFAULT nextval('migration_issues_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notification_policies ALTER COLUMN id SET DEFAULT nextval('notification_policies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_requests ALTER COLUMN id SET DEFAULT nextval('oauth_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY page_comments ALTER COLUMN id SET DEFAULT nextval('page_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY plugin_settings ALTER COLUMN id SET DEFAULT nextval('plugin_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_poll_choices ALTER COLUMN id SET DEFAULT nextval('polling_poll_choices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_poll_sessions ALTER COLUMN id SET DEFAULT nextval('polling_poll_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_poll_submissions ALTER COLUMN id SET DEFAULT nextval('polling_poll_submissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_polls ALTER COLUMN id SET DEFAULT nextval('polling_polls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY progresses ALTER COLUMN id SET DEFAULT nextval('progresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY project_courses ALTER COLUMN id SET DEFAULT nextval('project_courses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pseudonyms ALTER COLUMN id SET DEFAULT nextval('pseudonyms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_groups ALTER COLUMN id SET DEFAULT nextval('quiz_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_question_regrades ALTER COLUMN id SET DEFAULT nextval('quiz_question_regrades_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_questions ALTER COLUMN id SET DEFAULT nextval('quiz_questions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_regrade_runs ALTER COLUMN id SET DEFAULT nextval('quiz_regrade_runs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_regrades ALTER COLUMN id SET DEFAULT nextval('quiz_regrades_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_statistics ALTER COLUMN id SET DEFAULT nextval('quiz_statistics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_events ALTER COLUMN id SET DEFAULT nextval('quiz_submission_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_events_2014_11 ALTER COLUMN id SET DEFAULT nextval('quiz_submission_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_events_2014_12 ALTER COLUMN id SET DEFAULT nextval('quiz_submission_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_events_2015_1 ALTER COLUMN id SET DEFAULT nextval('quiz_submission_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_events_2015_2 ALTER COLUMN id SET DEFAULT nextval('quiz_submission_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_events_2015_3 ALTER COLUMN id SET DEFAULT nextval('quiz_submission_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_snapshots ALTER COLUMN id SET DEFAULT nextval('quiz_submission_snapshots_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submissions ALTER COLUMN id SET DEFAULT nextval('quiz_submissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY quizzes ALTER COLUMN id SET DEFAULT nextval('quizzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY report_snapshots ALTER COLUMN id SET DEFAULT nextval('report_snapshots_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY role_overrides ALTER COLUMN id SET DEFAULT nextval('role_overrides_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rubric_assessments ALTER COLUMN id SET DEFAULT nextval('rubric_assessments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rubric_associations ALTER COLUMN id SET DEFAULT nextval('rubric_associations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rubrics ALTER COLUMN id SET DEFAULT nextval('rubrics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scribd_mime_types ALTER COLUMN id SET DEFAULT nextval('scribd_mime_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY session_persistence_tokens ALTER COLUMN id SET DEFAULT nextval('session_persistence_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions ALTER COLUMN id SET DEFAULT nextval('sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sis_batches ALTER COLUMN id SET DEFAULT nextval('sis_batches_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sis_post_grades_statuses ALTER COLUMN id SET DEFAULT nextval('sis_post_grades_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stories ALTER COLUMN id SET DEFAULT nextval('stories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stream_item_instances ALTER COLUMN id SET DEFAULT nextval('stream_item_instances_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stream_items ALTER COLUMN id SET DEFAULT nextval('stream_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY submission_comment_participants ALTER COLUMN id SET DEFAULT nextval('submission_comment_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY submission_comments ALTER COLUMN id SET DEFAULT nextval('submission_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY submission_versions ALTER COLUMN id SET DEFAULT nextval('submission_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY submissions ALTER COLUMN id SET DEFAULT nextval('submissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY switchman_shards ALTER COLUMN id SET DEFAULT nextval('switchman_shards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY thumbnails ALTER COLUMN id SET DEFAULT nextval('thumbnails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY usage_rights ALTER COLUMN id SET DEFAULT nextval('usage_rights_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_account_associations ALTER COLUMN id SET DEFAULT nextval('user_account_associations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_notes ALTER COLUMN id SET DEFAULT nextval('user_notes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_observers ALTER COLUMN id SET DEFAULT nextval('user_observers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_profile_links ALTER COLUMN id SET DEFAULT nextval('user_profile_links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_profiles ALTER COLUMN id SET DEFAULT nextval('user_profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_services ALTER COLUMN id SET DEFAULT nextval('user_services_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_conference_participants ALTER COLUMN id SET DEFAULT nextval('web_conference_participants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_conferences ALTER COLUMN id SET DEFAULT nextval('web_conferences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wiki_pages ALTER COLUMN id SET DEFAULT nextval('wiki_pages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wikis ALTER COLUMN id SET DEFAULT nextval('wikis_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY zip_file_imports ALTER COLUMN id SET DEFAULT nextval('zip_file_imports_id_seq'::regclass);


--
-- Name: abstract_courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY abstract_courses
    ADD CONSTRAINT abstract_courses_pkey PRIMARY KEY (id);


--
-- Name: access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY access_tokens
    ADD CONSTRAINT access_tokens_pkey PRIMARY KEY (id);


--
-- Name: account_authorization_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_authorization_configs
    ADD CONSTRAINT account_authorization_configs_pkey PRIMARY KEY (id);


--
-- Name: account_notification_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_notification_roles
    ADD CONSTRAINT account_notification_roles_pkey PRIMARY KEY (id);


--
-- Name: account_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT account_notifications_pkey PRIMARY KEY (id);


--
-- Name: account_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_reports
    ADD CONSTRAINT account_reports_pkey PRIMARY KEY (id);


--
-- Name: account_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT account_users_pkey PRIMARY KEY (id);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: alert_criteria_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY alert_criteria
    ADD CONSTRAINT alert_criteria_pkey PRIMARY KEY (id);


--
-- Name: alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (id);


--
-- Name: appointment_group_contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appointment_group_contexts
    ADD CONSTRAINT appointment_group_contexts_pkey PRIMARY KEY (id);


--
-- Name: appointment_group_sub_contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appointment_group_sub_contexts
    ADD CONSTRAINT appointment_group_sub_contexts_pkey PRIMARY KEY (id);


--
-- Name: appointment_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY appointment_groups
    ADD CONSTRAINT appointment_groups_pkey PRIMARY KEY (id);


--
-- Name: assessment_question_bank_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assessment_question_bank_users
    ADD CONSTRAINT assessment_question_bank_users_pkey PRIMARY KEY (id);


--
-- Name: assessment_question_banks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assessment_question_banks
    ADD CONSTRAINT assessment_question_banks_pkey PRIMARY KEY (id);


--
-- Name: assessment_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assessment_questions
    ADD CONSTRAINT assessment_questions_pkey PRIMARY KEY (id);


--
-- Name: assessment_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assessment_requests
    ADD CONSTRAINT assessment_requests_pkey PRIMARY KEY (id);


--
-- Name: asset_user_accesses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY asset_user_accesses
    ADD CONSTRAINT asset_user_accesses_pkey PRIMARY KEY (id);


--
-- Name: assignment_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assignment_groups
    ADD CONSTRAINT assignment_groups_pkey PRIMARY KEY (id);


--
-- Name: assignment_override_students_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assignment_override_students
    ADD CONSTRAINT assignment_override_students_pkey PRIMARY KEY (id);


--
-- Name: assignment_overrides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assignment_overrides
    ADD CONSTRAINT assignment_overrides_pkey PRIMARY KEY (id);


--
-- Name: assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: attachment_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachment_associations
    ADD CONSTRAINT attachment_associations_pkey PRIMARY KEY (id);


--
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: authorization_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authorization_codes
    ADD CONSTRAINT authorization_codes_pkey PRIMARY KEY (id);


--
-- Name: calendar_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY calendar_events
    ADD CONSTRAINT calendar_events_pkey PRIMARY KEY (id);


--
-- Name: canvadocs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY canvadocs
    ADD CONSTRAINT canvadocs_pkey PRIMARY KEY (id);


--
-- Name: cloned_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cloned_items
    ADD CONSTRAINT cloned_items_pkey PRIMARY KEY (id);


--
-- Name: collaborations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collaborations
    ADD CONSTRAINT collaborations_pkey PRIMARY KEY (id);


--
-- Name: collaborators_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collaborators
    ADD CONSTRAINT collaborators_pkey PRIMARY KEY (id);


--
-- Name: communication_channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY communication_channels
    ADD CONSTRAINT communication_channels_pkey PRIMARY KEY (id);


--
-- Name: content_exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_exports
    ADD CONSTRAINT content_exports_pkey PRIMARY KEY (id);


--
-- Name: content_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_migrations
    ADD CONSTRAINT content_migrations_pkey PRIMARY KEY (id);


--
-- Name: content_participation_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_participation_counts
    ADD CONSTRAINT content_participation_counts_pkey PRIMARY KEY (id);


--
-- Name: content_participations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_participations
    ADD CONSTRAINT content_participations_pkey PRIMARY KEY (id);


--
-- Name: content_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY content_tags
    ADD CONSTRAINT content_tags_pkey PRIMARY KEY (id);


--
-- Name: context_external_tool_placements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY context_external_tool_placements
    ADD CONSTRAINT context_external_tool_placements_pkey PRIMARY KEY (id);


--
-- Name: context_external_tools_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY context_external_tools
    ADD CONSTRAINT context_external_tools_pkey PRIMARY KEY (id);


--
-- Name: context_message_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY context_message_participants
    ADD CONSTRAINT context_message_participants_pkey PRIMARY KEY (id);


--
-- Name: context_module_progressions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY context_module_progressions
    ADD CONSTRAINT context_module_progressions_pkey PRIMARY KEY (id);


--
-- Name: context_modules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY context_modules
    ADD CONSTRAINT context_modules_pkey PRIMARY KEY (id);


--
-- Name: conversation_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY conversation_batches
    ADD CONSTRAINT conversation_batches_pkey PRIMARY KEY (id);


--
-- Name: conversation_message_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY conversation_message_participants
    ADD CONSTRAINT conversation_message_participants_pkey PRIMARY KEY (id);


--
-- Name: conversation_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY conversation_messages
    ADD CONSTRAINT conversation_messages_pkey PRIMARY KEY (id);


--
-- Name: conversation_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY conversation_participants
    ADD CONSTRAINT conversation_participants_pkey PRIMARY KEY (id);


--
-- Name: conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: course_account_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY course_account_associations
    ADD CONSTRAINT course_account_associations_pkey PRIMARY KEY (id);


--
-- Name: course_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY course_imports
    ADD CONSTRAINT course_imports_pkey PRIMARY KEY (id);


--
-- Name: course_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY course_sections
    ADD CONSTRAINT course_sections_pkey PRIMARY KEY (id);


--
-- Name: courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);


--
-- Name: crocodoc_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY crocodoc_documents
    ADD CONSTRAINT crocodoc_documents_pkey PRIMARY KEY (id);


--
-- Name: custom_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY custom_data
    ADD CONSTRAINT custom_data_pkey PRIMARY KEY (id);


--
-- Name: custom_gradebook_column_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY custom_gradebook_column_data
    ADD CONSTRAINT custom_gradebook_column_data_pkey PRIMARY KEY (id);


--
-- Name: custom_gradebook_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY custom_gradebook_columns
    ADD CONSTRAINT custom_gradebook_columns_pkey PRIMARY KEY (id);


--
-- Name: data_exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY data_exports
    ADD CONSTRAINT data_exports_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: delayed_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_messages
    ADD CONSTRAINT delayed_messages_pkey PRIMARY KEY (id);


--
-- Name: delayed_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_notifications
    ADD CONSTRAINT delayed_notifications_pkey PRIMARY KEY (id);


--
-- Name: developer_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY developer_keys
    ADD CONSTRAINT developer_keys_pkey PRIMARY KEY (id);


--
-- Name: discussion_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY discussion_entries
    ADD CONSTRAINT discussion_entries_pkey PRIMARY KEY (id);


--
-- Name: discussion_entry_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY discussion_entry_participants
    ADD CONSTRAINT discussion_entry_participants_pkey PRIMARY KEY (id);


--
-- Name: discussion_topic_materialized_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY discussion_topic_materialized_views
    ADD CONSTRAINT discussion_topic_materialized_views_pkey PRIMARY KEY (discussion_topic_id);


--
-- Name: discussion_topic_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY discussion_topic_participants
    ADD CONSTRAINT discussion_topic_participants_pkey PRIMARY KEY (id);


--
-- Name: discussion_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY discussion_topics
    ADD CONSTRAINT discussion_topics_pkey PRIMARY KEY (id);


--
-- Name: enrollment_dates_overrides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enrollment_dates_overrides
    ADD CONSTRAINT enrollment_dates_overrides_pkey PRIMARY KEY (id);


--
-- Name: enrollment_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enrollment_terms
    ADD CONSTRAINT enrollment_terms_pkey PRIMARY KEY (id);


--
-- Name: enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (id);


--
-- Name: eportfolio_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eportfolio_categories
    ADD CONSTRAINT eportfolio_categories_pkey PRIMARY KEY (id);


--
-- Name: eportfolio_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eportfolio_entries
    ADD CONSTRAINT eportfolio_entries_pkey PRIMARY KEY (id);


--
-- Name: eportfolios_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY eportfolios
    ADD CONSTRAINT eportfolios_pkey PRIMARY KEY (id);


--
-- Name: error_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY error_reports
    ADD CONSTRAINT error_reports_pkey PRIMARY KEY (id);


--
-- Name: event_stream_failures_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY event_stream_failures
    ADD CONSTRAINT event_stream_failures_pkey PRIMARY KEY (id);


--
-- Name: external_feed_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY external_feed_entries
    ADD CONSTRAINT external_feed_entries_pkey PRIMARY KEY (id);


--
-- Name: external_feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY external_feeds
    ADD CONSTRAINT external_feeds_pkey PRIMARY KEY (id);


--
-- Name: external_integration_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY external_integration_keys
    ADD CONSTRAINT external_integration_keys_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: feature_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feature_flags
    ADD CONSTRAINT feature_flags_pkey PRIMARY KEY (id);


--
-- Name: folders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY folders
    ADD CONSTRAINT folders_pkey PRIMARY KEY (id);


--
-- Name: gradebook_uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gradebook_uploads
    ADD CONSTRAINT gradebook_uploads_pkey PRIMARY KEY (id);


--
-- Name: grading_period_grades_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY grading_period_grades
    ADD CONSTRAINT grading_period_grades_pkey PRIMARY KEY (id);


--
-- Name: grading_period_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY grading_period_groups
    ADD CONSTRAINT grading_period_groups_pkey PRIMARY KEY (id);


--
-- Name: grading_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY grading_periods
    ADD CONSTRAINT grading_periods_pkey PRIMARY KEY (id);


--
-- Name: grading_standards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY grading_standards
    ADD CONSTRAINT grading_standards_pkey PRIMARY KEY (id);


--
-- Name: group_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_categories
    ADD CONSTRAINT group_categories_pkey PRIMARY KEY (id);


--
-- Name: group_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_memberships
    ADD CONSTRAINT group_memberships_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: icl_individual_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY icl_individual_projects
    ADD CONSTRAINT icl_individual_projects_pkey PRIMARY KEY (id);


--
-- Name: icl_project_choices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY icl_project_choices
    ADD CONSTRAINT icl_project_choices_pkey PRIMARY KEY (id);


--
-- Name: icl_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY icl_projects
    ADD CONSTRAINT icl_projects_pkey PRIMARY KEY (id);


--
-- Name: ignores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ignores
    ADD CONSTRAINT ignores_pkey PRIMARY KEY (id);


--
-- Name: inbox_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inbox_items
    ADD CONSTRAINT inbox_items_pkey PRIMARY KEY (id);


--
-- Name: learning_outcome_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY learning_outcome_groups
    ADD CONSTRAINT learning_outcome_groups_pkey PRIMARY KEY (id);


--
-- Name: learning_outcome_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY learning_outcome_results
    ADD CONSTRAINT learning_outcome_results_pkey PRIMARY KEY (id);


--
-- Name: learning_outcomes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY learning_outcomes
    ADD CONSTRAINT learning_outcomes_pkey PRIMARY KEY (id);


--
-- Name: live_assessments_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY live_assessments_assessments
    ADD CONSTRAINT live_assessments_assessments_pkey PRIMARY KEY (id);


--
-- Name: live_assessments_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY live_assessments_results
    ADD CONSTRAINT live_assessments_results_pkey PRIMARY KEY (id);


--
-- Name: live_assessments_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY live_assessments_submissions
    ADD CONSTRAINT live_assessments_submissions_pkey PRIMARY KEY (id);


--
-- Name: lti_message_handlers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lti_message_handlers
    ADD CONSTRAINT lti_message_handlers_pkey PRIMARY KEY (id);


--
-- Name: lti_product_families_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lti_product_families
    ADD CONSTRAINT lti_product_families_pkey PRIMARY KEY (id);


--
-- Name: lti_resource_handlers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lti_resource_handlers
    ADD CONSTRAINT lti_resource_handlers_pkey PRIMARY KEY (id);


--
-- Name: lti_resource_placements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lti_resource_placements
    ADD CONSTRAINT lti_resource_placements_pkey PRIMARY KEY (id);


--
-- Name: lti_tool_proxies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lti_tool_proxies
    ADD CONSTRAINT lti_tool_proxies_pkey PRIMARY KEY (id);


--
-- Name: lti_tool_proxy_bindings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lti_tool_proxy_bindings
    ADD CONSTRAINT lti_tool_proxy_bindings_pkey PRIMARY KEY (id);


--
-- Name: lti_tool_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lti_tool_settings
    ADD CONSTRAINT lti_tool_settings_pkey PRIMARY KEY (id);


--
-- Name: media_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_objects
    ADD CONSTRAINT media_objects_pkey PRIMARY KEY (id);


--
-- Name: media_tracks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_tracks
    ADD CONSTRAINT media_tracks_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: migration_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY migration_issues
    ADD CONSTRAINT migration_issues_pkey PRIMARY KEY (id);


--
-- Name: notification_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notification_policies
    ADD CONSTRAINT notification_policies_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_requests
    ADD CONSTRAINT oauth_requests_pkey PRIMARY KEY (id);


--
-- Name: page_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY page_comments
    ADD CONSTRAINT page_comments_pkey PRIMARY KEY (id);


--
-- Name: page_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY page_views
    ADD CONSTRAINT page_views_pkey PRIMARY KEY (request_id);


--
-- Name: plugin_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plugin_settings
    ADD CONSTRAINT plugin_settings_pkey PRIMARY KEY (id);


--
-- Name: polling_poll_choices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY polling_poll_choices
    ADD CONSTRAINT polling_poll_choices_pkey PRIMARY KEY (id);


--
-- Name: polling_poll_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY polling_poll_sessions
    ADD CONSTRAINT polling_poll_sessions_pkey PRIMARY KEY (id);


--
-- Name: polling_poll_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY polling_poll_submissions
    ADD CONSTRAINT polling_poll_submissions_pkey PRIMARY KEY (id);


--
-- Name: polling_polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY polling_polls
    ADD CONSTRAINT polling_polls_pkey PRIMARY KEY (id);


--
-- Name: profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: progresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY progresses
    ADD CONSTRAINT progresses_pkey PRIMARY KEY (id);


--
-- Name: project_courses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY project_courses
    ADD CONSTRAINT project_courses_pkey PRIMARY KEY (id);


--
-- Name: pseudonyms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pseudonyms
    ADD CONSTRAINT pseudonyms_pkey PRIMARY KEY (id);


--
-- Name: quiz_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_groups
    ADD CONSTRAINT quiz_groups_pkey PRIMARY KEY (id);


--
-- Name: quiz_question_regrades_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_question_regrades
    ADD CONSTRAINT quiz_question_regrades_pkey PRIMARY KEY (id);


--
-- Name: quiz_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_questions
    ADD CONSTRAINT quiz_questions_pkey PRIMARY KEY (id);


--
-- Name: quiz_regrade_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_regrade_runs
    ADD CONSTRAINT quiz_regrade_runs_pkey PRIMARY KEY (id);


--
-- Name: quiz_regrades_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_regrades
    ADD CONSTRAINT quiz_regrades_pkey PRIMARY KEY (id);


--
-- Name: quiz_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_statistics
    ADD CONSTRAINT quiz_statistics_pkey PRIMARY KEY (id);


--
-- Name: quiz_submission_events_2014_11_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_submission_events_2014_11
    ADD CONSTRAINT quiz_submission_events_2014_11_pkey PRIMARY KEY (id);


--
-- Name: quiz_submission_events_2014_12_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_submission_events_2014_12
    ADD CONSTRAINT quiz_submission_events_2014_12_pkey PRIMARY KEY (id);


--
-- Name: quiz_submission_events_2015_1_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_submission_events_2015_1
    ADD CONSTRAINT quiz_submission_events_2015_1_pkey PRIMARY KEY (id);


--
-- Name: quiz_submission_events_2015_2_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_submission_events_2015_2
    ADD CONSTRAINT quiz_submission_events_2015_2_pkey PRIMARY KEY (id);


--
-- Name: quiz_submission_events_2015_3_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_submission_events_2015_3
    ADD CONSTRAINT quiz_submission_events_2015_3_pkey PRIMARY KEY (id);


--
-- Name: quiz_submission_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_submission_events
    ADD CONSTRAINT quiz_submission_events_pkey PRIMARY KEY (id);


--
-- Name: quiz_submission_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_submission_snapshots
    ADD CONSTRAINT quiz_submission_snapshots_pkey PRIMARY KEY (id);


--
-- Name: quiz_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quiz_submissions
    ADD CONSTRAINT quiz_submissions_pkey PRIMARY KEY (id);


--
-- Name: quizzes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: report_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY report_snapshots
    ADD CONSTRAINT report_snapshots_pkey PRIMARY KEY (id);


--
-- Name: role_overrides_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY role_overrides
    ADD CONSTRAINT role_overrides_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: rubric_assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rubric_assessments
    ADD CONSTRAINT rubric_assessments_pkey PRIMARY KEY (id);


--
-- Name: rubric_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rubric_associations
    ADD CONSTRAINT rubric_associations_pkey PRIMARY KEY (id);


--
-- Name: rubrics_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rubrics
    ADD CONSTRAINT rubrics_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: scribd_mime_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scribd_mime_types
    ADD CONSTRAINT scribd_mime_types_pkey PRIMARY KEY (id);


--
-- Name: session_persistence_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY session_persistence_tokens
    ADD CONSTRAINT session_persistence_tokens_pkey PRIMARY KEY (id);


--
-- Name: sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: sis_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sis_batches
    ADD CONSTRAINT sis_batches_pkey PRIMARY KEY (id);


--
-- Name: sis_post_grades_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sis_post_grades_statuses
    ADD CONSTRAINT sis_post_grades_statuses_pkey PRIMARY KEY (id);


--
-- Name: stories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stories
    ADD CONSTRAINT stories_pkey PRIMARY KEY (id);


--
-- Name: stream_item_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stream_item_instances
    ADD CONSTRAINT stream_item_instances_pkey PRIMARY KEY (id);


--
-- Name: stream_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stream_items
    ADD CONSTRAINT stream_items_pkey PRIMARY KEY (id);


--
-- Name: submission_comment_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY submission_comment_participants
    ADD CONSTRAINT submission_comment_participants_pkey PRIMARY KEY (id);


--
-- Name: submission_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY submission_comments
    ADD CONSTRAINT submission_comments_pkey PRIMARY KEY (id);


--
-- Name: submission_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY submission_versions
    ADD CONSTRAINT submission_versions_pkey PRIMARY KEY (id);


--
-- Name: submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: switchman_shards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY switchman_shards
    ADD CONSTRAINT switchman_shards_pkey PRIMARY KEY (id);


--
-- Name: thumbnails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY thumbnails
    ADD CONSTRAINT thumbnails_pkey PRIMARY KEY (id);


--
-- Name: usage_rights_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY usage_rights
    ADD CONSTRAINT usage_rights_pkey PRIMARY KEY (id);


--
-- Name: user_account_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_account_associations
    ADD CONSTRAINT user_account_associations_pkey PRIMARY KEY (id);


--
-- Name: user_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_notes
    ADD CONSTRAINT user_notes_pkey PRIMARY KEY (id);


--
-- Name: user_observers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_observers
    ADD CONSTRAINT user_observers_pkey PRIMARY KEY (id);


--
-- Name: user_profile_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_profile_links
    ADD CONSTRAINT user_profile_links_pkey PRIMARY KEY (id);


--
-- Name: user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (id);


--
-- Name: user_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_services
    ADD CONSTRAINT user_services_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: web_conference_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_conference_participants
    ADD CONSTRAINT web_conference_participants_pkey PRIMARY KEY (id);


--
-- Name: web_conferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_conferences
    ADD CONSTRAINT web_conferences_pkey PRIMARY KEY (id);


--
-- Name: wiki_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wiki_pages
    ADD CONSTRAINT wiki_pages_pkey PRIMARY KEY (id);


--
-- Name: wikis_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wikis
    ADD CONSTRAINT wikis_pkey PRIMARY KEY (id);


--
-- Name: zip_file_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zip_file_imports
    ADD CONSTRAINT zip_file_imports_pkey PRIMARY KEY (id);


--
-- Name: aa_id_and_aa_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX aa_id_and_aa_type ON assessment_requests USING btree (assessor_asset_id, assessor_asset_type);


--
-- Name: assessment_qbu_aqb_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX assessment_qbu_aqb_id ON assessment_question_bank_users USING btree (assessment_question_bank_id);


--
-- Name: assessment_qbu_u_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX assessment_qbu_u_id ON assessment_question_bank_users USING btree (user_id);


--
-- Name: attachment_associations_a_id_a_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX attachment_associations_a_id_a_type ON attachment_associations USING btree (context_id, context_type);


--
-- Name: by_sent_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX by_sent_at ON delayed_messages USING btree (send_at);


--
-- Name: ccid_raid_ws_sa; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ccid_raid_ws_sa ON delayed_messages USING btree (communication_channel_id, root_account_id, workflow_state, send_at);


--
-- Name: error_reports_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX error_reports_created_at ON error_reports USING btree (created_at);


--
-- Name: event_predecessor_locator_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX event_predecessor_locator_index ON quiz_submission_events USING btree (quiz_submission_id, attempt, created_at);


--
-- Name: existing_undispatched_message; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX existing_undispatched_message ON messages USING btree (context_id, context_type, notification_name, "to", user_id);


--
-- Name: external_tool_placements_tool_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX external_tool_placements_tool_id ON context_external_tool_placements USING btree (context_external_tool_id);


--
-- Name: external_tool_placements_type_and_tool_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX external_tool_placements_type_and_tool_id ON context_external_tool_placements USING btree (placement_type, context_external_tool_id);


--
-- Name: external_tools_integration_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX external_tools_integration_type ON context_external_tools USING btree (context_id, context_type, integration_type);


--
-- Name: get_delayed_jobs_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX get_delayed_jobs_index ON delayed_jobs USING btree (priority, run_at) WHERE (((locked_at IS NULL) AND ((queue)::text = 'canvas_queue'::text)) AND (next_in_strand = true));


--
-- Name: idx_qqs_on_quiz_and_aq_ids; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_qqs_on_quiz_and_aq_ids ON quiz_questions USING btree (quiz_id, assessment_question_id);


--
-- Name: index_abstract_courses_on_enrollment_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_abstract_courses_on_enrollment_term_id ON abstract_courses USING btree (enrollment_term_id);


--
-- Name: index_abstract_courses_on_root_account_id_and_sis_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_abstract_courses_on_root_account_id_and_sis_source_id ON abstract_courses USING btree (root_account_id, sis_source_id);


--
-- Name: index_abstract_courses_on_sis_batch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_abstract_courses_on_sis_batch_id ON abstract_courses USING btree (sis_batch_id) WHERE (sis_batch_id IS NOT NULL);


--
-- Name: index_abstract_courses_on_sis_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_abstract_courses_on_sis_source_id ON abstract_courses USING btree (sis_source_id);


--
-- Name: index_access_tokens_on_crypted_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_access_tokens_on_crypted_token ON access_tokens USING btree (crypted_token);


--
-- Name: index_account_authorization_configs_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_authorization_configs_on_account_id ON account_authorization_configs USING btree (account_id);


--
-- Name: index_account_notification_roles_on_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_account_notification_roles_on_role_id ON account_notification_roles USING btree (account_notification_id, role_id);


--
-- Name: index_account_notifications_by_account_and_timespan; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_notifications_by_account_and_timespan ON account_notifications USING btree (account_id, end_at, start_at);


--
-- Name: index_account_reports_on_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_reports_on_attachment_id ON account_reports USING btree (attachment_id);


--
-- Name: index_account_users_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_users_on_account_id ON account_users USING btree (account_id);


--
-- Name: index_account_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_account_users_on_user_id ON account_users USING btree (user_id);


--
-- Name: index_accounts_on_integration_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_accounts_on_integration_id ON accounts USING btree (integration_id, root_account_id) WHERE (integration_id IS NOT NULL);


--
-- Name: index_accounts_on_lti_context_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_accounts_on_lti_context_id ON accounts USING btree (lti_context_id);


--
-- Name: index_accounts_on_name_and_parent_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_name_and_parent_account_id ON accounts USING btree (name, parent_account_id);


--
-- Name: index_accounts_on_parent_account_id_and_root_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_parent_account_id_and_root_account_id ON accounts USING btree (parent_account_id, root_account_id);


--
-- Name: index_accounts_on_root_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_root_account_id ON accounts USING btree (root_account_id);


--
-- Name: index_accounts_on_sis_batch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_sis_batch_id ON accounts USING btree (sis_batch_id) WHERE (sis_batch_id IS NOT NULL);


--
-- Name: index_accounts_on_sis_source_id_and_root_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_accounts_on_sis_source_id_and_root_account_id ON accounts USING btree (sis_source_id, root_account_id) WHERE (sis_source_id IS NOT NULL);


--
-- Name: index_appointment_group_contexts_on_appointment_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_appointment_group_contexts_on_appointment_group_id ON appointment_group_contexts USING btree (appointment_group_id);


--
-- Name: index_appointment_group_sub_contexts_on_appointment_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_appointment_group_sub_contexts_on_appointment_group_id ON appointment_group_sub_contexts USING btree (appointment_group_id);


--
-- Name: index_appointment_groups_on_context_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_appointment_groups_on_context_id ON appointment_groups USING btree (context_id);


--
-- Name: index_assessment_requests_on_assessor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assessment_requests_on_assessor_id ON assessment_requests USING btree (assessor_id);


--
-- Name: index_assessment_requests_on_asset_id_and_asset_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assessment_requests_on_asset_id_and_asset_type ON assessment_requests USING btree (asset_id, asset_type);


--
-- Name: index_assessment_requests_on_rubric_assessment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assessment_requests_on_rubric_assessment_id ON assessment_requests USING btree (rubric_assessment_id);


--
-- Name: index_assessment_requests_on_rubric_association_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assessment_requests_on_rubric_association_id ON assessment_requests USING btree (rubric_association_id);


--
-- Name: index_assessment_requests_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assessment_requests_on_user_id ON assessment_requests USING btree (user_id);


--
-- Name: index_asset_user_accesses_on_ci_ct_ui_ua; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_asset_user_accesses_on_ci_ct_ui_ua ON asset_user_accesses USING btree (context_id, context_type, user_id, updated_at);


--
-- Name: index_asset_user_accesses_on_user_id_and_asset_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_asset_user_accesses_on_user_id_and_asset_code ON asset_user_accesses USING btree (user_id, asset_code);


--
-- Name: index_assignment_groups_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignment_groups_on_context_id_and_context_type ON assignment_groups USING btree (context_id, context_type);


--
-- Name: index_assignment_override_students_on_assignment_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_assignment_override_students_on_assignment_id_and_user_id ON assignment_override_students USING btree (assignment_id, user_id);


--
-- Name: index_assignment_override_students_on_assignment_override_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignment_override_students_on_assignment_override_id ON assignment_override_students USING btree (assignment_override_id);


--
-- Name: index_assignment_override_students_on_quiz_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignment_override_students_on_quiz_id ON assignment_override_students USING btree (quiz_id);


--
-- Name: index_assignment_override_students_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignment_override_students_on_user_id ON assignment_override_students USING btree (user_id);


--
-- Name: index_assignment_overrides_on_assignment_and_set; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_assignment_overrides_on_assignment_and_set ON assignment_overrides USING btree (assignment_id, set_type, set_id) WHERE (((workflow_state)::text = 'active'::text) AND (set_id IS NOT NULL));


--
-- Name: index_assignment_overrides_on_assignment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignment_overrides_on_assignment_id ON assignment_overrides USING btree (assignment_id);


--
-- Name: index_assignment_overrides_on_quiz_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignment_overrides_on_quiz_id ON assignment_overrides USING btree (quiz_id);


--
-- Name: index_assignment_overrides_on_set_type_and_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignment_overrides_on_set_type_and_set_id ON assignment_overrides USING btree (set_type, set_id);


--
-- Name: index_assignments_on_assignment_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignments_on_assignment_group_id ON assignments USING btree (assignment_group_id);


--
-- Name: index_assignments_on_context_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignments_on_context_code ON assignments USING btree (context_code);


--
-- Name: index_assignments_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignments_on_context_id_and_context_type ON assignments USING btree (context_id, context_type);


--
-- Name: index_assignments_on_due_at_and_context_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignments_on_due_at_and_context_code ON assignments USING btree (due_at, context_code);


--
-- Name: index_assignments_on_grading_standard_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignments_on_grading_standard_id ON assignments USING btree (grading_standard_id);


--
-- Name: index_attachment_associations_on_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachment_associations_on_attachment_id ON attachment_associations USING btree (attachment_id);


--
-- Name: index_attachments_on_cloned_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_cloned_item_id ON attachments USING btree (cloned_item_id);


--
-- Name: index_attachments_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_context_id_and_context_type ON attachments USING btree (context_id, context_type);


--
-- Name: index_attachments_on_folder_id_and_file_state_and_display_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_folder_id_and_file_state_and_display_name ON attachments USING btree (folder_id, file_state, ((lower(replace(display_name, '\'::text, '\\'::text)))::bytea)) WHERE (folder_id IS NOT NULL);


--
-- Name: index_attachments_on_folder_id_and_file_state_and_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_folder_id_and_file_state_and_position ON attachments USING btree (folder_id, file_state, "position");


--
-- Name: index_attachments_on_md5_and_namespace; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_md5_and_namespace ON attachments USING btree (md5, namespace);


--
-- Name: index_attachments_on_need_notify; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_need_notify ON attachments USING btree (need_notify) WHERE need_notify;


--
-- Name: index_attachments_on_replacement_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_replacement_attachment_id ON attachments USING btree (replacement_attachment_id) WHERE (replacement_attachment_id IS NOT NULL);


--
-- Name: index_attachments_on_root_attachment_id_not_null; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_root_attachment_id_not_null ON attachments USING btree (root_attachment_id) WHERE (root_attachment_id IS NOT NULL);


--
-- Name: index_attachments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_user_id ON attachments USING btree (user_id);


--
-- Name: index_attachments_on_workflow_state_and_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_attachments_on_workflow_state_and_updated_at ON attachments USING btree (workflow_state, updated_at);


--
-- Name: index_authorization_codes_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_authorization_codes_on_account_id ON authorization_codes USING btree (account_id);


--
-- Name: index_caa_on_course_id_and_section_id_and_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_caa_on_course_id_and_section_id_and_account_id ON course_account_associations USING btree (course_id, course_section_id, account_id);


--
-- Name: index_calendar_events_on_context_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_calendar_events_on_context_code ON calendar_events USING btree (context_code);


--
-- Name: index_calendar_events_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_calendar_events_on_context_id_and_context_type ON calendar_events USING btree (context_id, context_type);


--
-- Name: index_calendar_events_on_effective_context_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_calendar_events_on_effective_context_code ON calendar_events USING btree (effective_context_code) WHERE (effective_context_code IS NOT NULL);


--
-- Name: index_calendar_events_on_parent_calendar_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_calendar_events_on_parent_calendar_event_id ON calendar_events USING btree (parent_calendar_event_id);


--
-- Name: index_calendar_events_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_calendar_events_on_user_id ON calendar_events USING btree (user_id);


--
-- Name: index_canvadocs_on_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_canvadocs_on_attachment_id ON canvadocs USING btree (attachment_id);


--
-- Name: index_canvadocs_on_document_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_canvadocs_on_document_id ON canvadocs USING btree (document_id);


--
-- Name: index_canvadocs_on_process_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_canvadocs_on_process_state ON canvadocs USING btree (process_state);


--
-- Name: index_cmp_on_cpi_and_cmi; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cmp_on_cpi_and_cmi ON conversation_message_participants USING btree (conversation_participant_id, conversation_message_id);


--
-- Name: index_cmp_on_user_id_and_module_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_cmp_on_user_id_and_module_id ON context_module_progressions USING btree (user_id, context_module_id);


--
-- Name: index_collaborations_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collaborations_on_context_id_and_context_type ON collaborations USING btree (context_id, context_type);


--
-- Name: index_collaborations_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collaborations_on_user_id ON collaborations USING btree (user_id);


--
-- Name: index_collaborators_on_collaboration_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collaborators_on_collaboration_id ON collaborators USING btree (collaboration_id);


--
-- Name: index_collaborators_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collaborators_on_group_id ON collaborators USING btree (group_id);


--
-- Name: index_collaborators_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collaborators_on_user_id ON collaborators USING btree (user_id);


--
-- Name: index_communication_channels_on_confirmation_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_communication_channels_on_confirmation_code ON communication_channels USING btree (confirmation_code);


--
-- Name: index_communication_channels_on_path_and_path_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_communication_channels_on_path_and_path_type ON communication_channels USING btree (lower((path)::text), path_type);


--
-- Name: index_communication_channels_on_pseudonym_id_and_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_communication_channels_on_pseudonym_id_and_position ON communication_channels USING btree (pseudonym_id, "position");


--
-- Name: index_communication_channels_on_user_id_and_path_and_path_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_communication_channels_on_user_id_and_path_and_path_type ON communication_channels USING btree (user_id, lower((path)::text), path_type);


--
-- Name: index_communication_channels_on_user_id_and_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_communication_channels_on_user_id_and_position ON communication_channels USING btree (user_id, "position");


--
-- Name: index_content_exports_on_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_exports_on_attachment_id ON content_exports USING btree (attachment_id);


--
-- Name: index_content_exports_on_content_migration_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_exports_on_content_migration_id ON content_exports USING btree (content_migration_id);


--
-- Name: index_content_migrations_on_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_migrations_on_attachment_id ON content_migrations USING btree (attachment_id) WHERE (attachment_id IS NOT NULL);


--
-- Name: index_content_migrations_on_context_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_migrations_on_context_id ON content_migrations USING btree (context_id);


--
-- Name: index_content_migrations_on_exported_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_migrations_on_exported_attachment_id ON content_migrations USING btree (exported_attachment_id) WHERE (exported_attachment_id IS NOT NULL);


--
-- Name: index_content_migrations_on_overview_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_migrations_on_overview_attachment_id ON content_migrations USING btree (overview_attachment_id) WHERE (overview_attachment_id IS NOT NULL);


--
-- Name: index_content_migrations_on_source_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_migrations_on_source_course_id ON content_migrations USING btree (source_course_id) WHERE (source_course_id IS NOT NULL);


--
-- Name: index_content_participation_counts_uniquely; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_content_participation_counts_uniquely ON content_participation_counts USING btree (context_id, context_type, user_id, content_type);


--
-- Name: index_content_participations_uniquely; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_content_participations_uniquely ON content_participations USING btree (content_id, content_type, user_id);


--
-- Name: index_content_tags_on_associated_asset; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_tags_on_associated_asset ON content_tags USING btree (associated_asset_id, associated_asset_type);


--
-- Name: index_content_tags_on_content_id_and_content_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_tags_on_content_id_and_content_type ON content_tags USING btree (content_id, content_type);


--
-- Name: index_content_tags_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_tags_on_context_id_and_context_type ON content_tags USING btree (context_id, context_type);


--
-- Name: index_content_tags_on_context_module_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_tags_on_context_module_id ON content_tags USING btree (context_module_id);


--
-- Name: index_content_tags_on_learning_outcome_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_content_tags_on_learning_outcome_id ON content_tags USING btree (learning_outcome_id) WHERE (learning_outcome_id IS NOT NULL);


--
-- Name: index_context_external_tools_on_tool_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_context_external_tools_on_tool_id ON context_external_tools USING btree (tool_id);


--
-- Name: index_context_message_participants_on_context_message_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_context_message_participants_on_context_message_id ON context_message_participants USING btree (context_message_id);


--
-- Name: index_context_message_participants_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_context_message_participants_on_user_id ON context_message_participants USING btree (user_id);


--
-- Name: index_context_module_progressions_on_context_module_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_context_module_progressions_on_context_module_id ON context_module_progressions USING btree (context_module_id);


--
-- Name: index_context_modules_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_context_modules_on_context_id_and_context_type ON context_modules USING btree (context_id, context_type);


--
-- Name: index_conversation_batches_on_user_id_and_workflow_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_conversation_batches_on_user_id_and_workflow_state ON conversation_batches USING btree (user_id, workflow_state);


--
-- Name: index_conversation_message_participants_on_message_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_conversation_message_participants_on_message_id ON conversation_message_participants USING btree (conversation_message_id);


--
-- Name: index_conversation_message_participants_on_uid_and_message_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_conversation_message_participants_on_uid_and_message_id ON conversation_message_participants USING btree (user_id, conversation_message_id);


--
-- Name: index_conversation_messages_on_asset_id_and_asset_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_conversation_messages_on_asset_id_and_asset_type ON conversation_messages USING btree (asset_id, asset_type) WHERE (asset_id IS NOT NULL);


--
-- Name: index_conversation_messages_on_author_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_conversation_messages_on_author_id ON conversation_messages USING btree (author_id);


--
-- Name: index_conversation_messages_on_conversation_id_and_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_conversation_messages_on_conversation_id_and_created_at ON conversation_messages USING btree (conversation_id, created_at);


--
-- Name: index_conversation_participants_on_conversation_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_conversation_participants_on_conversation_id_and_user_id ON conversation_participants USING btree (conversation_id, user_id);


--
-- Name: index_conversation_participants_on_private_hash_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_conversation_participants_on_private_hash_and_user_id ON conversation_participants USING btree (private_hash, user_id) WHERE (private_hash IS NOT NULL);


--
-- Name: index_conversation_participants_on_user_id_and_last_message_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_conversation_participants_on_user_id_and_last_message_at ON conversation_participants USING btree (user_id, last_message_at);


--
-- Name: index_conversations_on_private_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_conversations_on_private_hash ON conversations USING btree (private_hash);


--
-- Name: index_course_account_associations_on_account_id_and_depth_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_account_associations_on_account_id_and_depth_id ON course_account_associations USING btree (account_id, depth);


--
-- Name: index_course_account_associations_on_course_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_account_associations_on_course_section_id ON course_account_associations USING btree (course_section_id);


--
-- Name: index_course_imports_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_imports_on_course_id ON course_imports USING btree (course_id);


--
-- Name: index_course_imports_on_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_imports_on_source_id ON course_imports USING btree (source_id);


--
-- Name: index_course_sections_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_sections_on_course_id ON course_sections USING btree (course_id);


--
-- Name: index_course_sections_on_enrollment_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_sections_on_enrollment_term_id ON course_sections USING btree (enrollment_term_id);


--
-- Name: index_course_sections_on_nonxlist_course; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_sections_on_nonxlist_course ON course_sections USING btree (nonxlist_course_id) WHERE (nonxlist_course_id IS NOT NULL);


--
-- Name: index_course_sections_on_root_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_sections_on_root_account_id ON course_sections USING btree (root_account_id);


--
-- Name: index_course_sections_on_sis_batch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_course_sections_on_sis_batch_id ON course_sections USING btree (sis_batch_id) WHERE (sis_batch_id IS NOT NULL);


--
-- Name: index_course_sections_on_sis_source_id_and_root_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_course_sections_on_sis_source_id_and_root_account_id ON course_sections USING btree (sis_source_id, root_account_id) WHERE (sis_source_id IS NOT NULL);


--
-- Name: index_courses_on_abstract_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_courses_on_abstract_course_id ON courses USING btree (abstract_course_id) WHERE (abstract_course_id IS NOT NULL);


--
-- Name: index_courses_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_courses_on_account_id ON courses USING btree (account_id);


--
-- Name: index_courses_on_enrollment_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_courses_on_enrollment_term_id ON courses USING btree (enrollment_term_id);


--
-- Name: index_courses_on_integration_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_courses_on_integration_id ON courses USING btree (integration_id, root_account_id) WHERE (integration_id IS NOT NULL);


--
-- Name: index_courses_on_lti_context_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_courses_on_lti_context_id ON courses USING btree (lti_context_id);


--
-- Name: index_courses_on_root_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_courses_on_root_account_id ON courses USING btree (root_account_id);


--
-- Name: index_courses_on_self_enrollment_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_courses_on_self_enrollment_code ON courses USING btree (self_enrollment_code) WHERE (self_enrollment_code IS NOT NULL);


--
-- Name: index_courses_on_sis_batch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_courses_on_sis_batch_id ON courses USING btree (sis_batch_id) WHERE (sis_batch_id IS NOT NULL);


--
-- Name: index_courses_on_sis_source_id_and_root_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_courses_on_sis_source_id_and_root_account_id ON courses USING btree (sis_source_id, root_account_id) WHERE (sis_source_id IS NOT NULL);


--
-- Name: index_courses_on_template_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_courses_on_template_course_id ON courses USING btree (template_course_id);


--
-- Name: index_courses_on_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_courses_on_uuid ON courses USING btree (uuid);


--
-- Name: index_courses_on_wiki_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_courses_on_wiki_id ON courses USING btree (wiki_id) WHERE (wiki_id IS NOT NULL);


--
-- Name: index_crocodoc_documents_on_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_crocodoc_documents_on_attachment_id ON crocodoc_documents USING btree (attachment_id);


--
-- Name: index_crocodoc_documents_on_process_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_crocodoc_documents_on_process_state ON crocodoc_documents USING btree (process_state);


--
-- Name: index_crocodoc_documents_on_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_crocodoc_documents_on_uuid ON crocodoc_documents USING btree (uuid);


--
-- Name: index_custom_data_on_user_id_and_namespace; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_custom_data_on_user_id_and_namespace ON custom_data USING btree (user_id, namespace);


--
-- Name: index_custom_gradebook_column_data_unique_column_and_user; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_custom_gradebook_column_data_unique_column_and_user ON custom_gradebook_column_data USING btree (custom_gradebook_column_id, user_id);


--
-- Name: index_custom_gradebook_columns_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_custom_gradebook_columns_on_course_id ON custom_gradebook_columns USING btree (course_id);


--
-- Name: index_data_exports_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_data_exports_on_context_id_and_context_type ON data_exports USING btree (context_id, context_type);


--
-- Name: index_data_exports_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_data_exports_on_user_id ON data_exports USING btree (user_id);


--
-- Name: index_delayed_jobs_on_locked_by; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delayed_jobs_on_locked_by ON delayed_jobs USING btree (locked_by) WHERE (locked_by IS NOT NULL);


--
-- Name: index_delayed_jobs_on_run_at_and_tag; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delayed_jobs_on_run_at_and_tag ON delayed_jobs USING btree (run_at, tag);


--
-- Name: index_delayed_jobs_on_strand; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delayed_jobs_on_strand ON delayed_jobs USING btree (strand, id);


--
-- Name: index_delayed_jobs_on_tag; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delayed_jobs_on_tag ON delayed_jobs USING btree (tag);


--
-- Name: index_delayed_messages_on_notification_policy_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delayed_messages_on_notification_policy_id ON delayed_messages USING btree (notification_policy_id);


--
-- Name: index_developer_keys_on_tool_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_developer_keys_on_tool_id ON developer_keys USING btree (tool_id);


--
-- Name: index_discussion_entries_for_topic; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_entries_for_topic ON discussion_entries USING btree (discussion_topic_id, updated_at, created_at);


--
-- Name: index_discussion_entries_on_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_entries_on_attachment_id ON discussion_entries USING btree (attachment_id) WHERE (attachment_id IS NOT NULL);


--
-- Name: index_discussion_entries_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_entries_on_parent_id ON discussion_entries USING btree (parent_id);


--
-- Name: index_discussion_entries_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_entries_on_user_id ON discussion_entries USING btree (user_id);


--
-- Name: index_discussion_entries_root_entry; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_entries_root_entry ON discussion_entries USING btree (root_entry_id, workflow_state, created_at);


--
-- Name: index_discussion_topics_on_assignment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_topics_on_assignment_id ON discussion_topics USING btree (assignment_id);


--
-- Name: index_discussion_topics_on_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_topics_on_attachment_id ON discussion_topics USING btree (attachment_id) WHERE (attachment_id IS NOT NULL);


--
-- Name: index_discussion_topics_on_context_and_last_reply_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_topics_on_context_and_last_reply_at ON discussion_topics USING btree (context_id, last_reply_at);


--
-- Name: index_discussion_topics_on_context_id_and_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_topics_on_context_id_and_position ON discussion_topics USING btree (context_id, "position");


--
-- Name: index_discussion_topics_on_external_feed_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_topics_on_external_feed_id ON discussion_topics USING btree (external_feed_id) WHERE (external_feed_id IS NOT NULL);


--
-- Name: index_discussion_topics_on_id_and_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_topics_on_id_and_type ON discussion_topics USING btree (id, type);


--
-- Name: index_discussion_topics_on_old_assignment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_topics_on_old_assignment_id ON discussion_topics USING btree (old_assignment_id) WHERE (old_assignment_id IS NOT NULL);


--
-- Name: index_discussion_topics_on_root_topic_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_topics_on_root_topic_id ON discussion_topics USING btree (root_topic_id);


--
-- Name: index_discussion_topics_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_topics_on_user_id ON discussion_topics USING btree (user_id);


--
-- Name: index_discussion_topics_on_workflow_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_discussion_topics_on_workflow_state ON discussion_topics USING btree (workflow_state);


--
-- Name: index_discussion_topics_unique_subtopic_per_context; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_discussion_topics_unique_subtopic_per_context ON discussion_topics USING btree (context_id, context_type, root_topic_id);


--
-- Name: index_enrollment_dates_overrides_on_enrollment_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enrollment_dates_overrides_on_enrollment_term_id ON enrollment_dates_overrides USING btree (enrollment_term_id);


--
-- Name: index_enrollment_terms_on_root_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enrollment_terms_on_root_account_id ON enrollment_terms USING btree (root_account_id);


--
-- Name: index_enrollment_terms_on_sis_batch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enrollment_terms_on_sis_batch_id ON enrollment_terms USING btree (sis_batch_id) WHERE (sis_batch_id IS NOT NULL);


--
-- Name: index_enrollment_terms_on_sis_source_id_and_root_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_enrollment_terms_on_sis_source_id_and_root_account_id ON enrollment_terms USING btree (sis_source_id, root_account_id) WHERE (sis_source_id IS NOT NULL);


--
-- Name: index_enrollments_on_associated_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enrollments_on_associated_user_id ON enrollments USING btree (associated_user_id) WHERE (associated_user_id IS NOT NULL);


--
-- Name: index_enrollments_on_course_id_and_workflow_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enrollments_on_course_id_and_workflow_state ON enrollments USING btree (course_id, workflow_state);


--
-- Name: index_enrollments_on_course_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enrollments_on_course_section_id ON enrollments USING btree (course_section_id);


--
-- Name: index_enrollments_on_root_account_id_and_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enrollments_on_root_account_id_and_course_id ON enrollments USING btree (root_account_id, course_id);


--
-- Name: index_enrollments_on_sis_batch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enrollments_on_sis_batch_id ON enrollments USING btree (sis_batch_id) WHERE (sis_batch_id IS NOT NULL);


--
-- Name: index_enrollments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enrollments_on_user_id ON enrollments USING btree (user_id);


--
-- Name: index_enrollments_on_user_type_role_section; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_enrollments_on_user_type_role_section ON enrollments USING btree (user_id, type, role_id, course_section_id) WHERE (associated_user_id IS NULL);


--
-- Name: index_enrollments_on_user_type_role_section_associated_user; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_enrollments_on_user_type_role_section_associated_user ON enrollments USING btree (user_id, type, role_id, course_section_id, associated_user_id) WHERE (associated_user_id IS NOT NULL);


--
-- Name: index_enrollments_on_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enrollments_on_uuid ON enrollments USING btree (uuid);


--
-- Name: index_enrollments_on_workflow_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_enrollments_on_workflow_state ON enrollments USING btree (workflow_state);


--
-- Name: index_entry_participant_on_entry_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_entry_participant_on_entry_id_and_user_id ON discussion_entry_participants USING btree (discussion_entry_id, user_id);


--
-- Name: index_eportfolio_categories_on_eportfolio_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_eportfolio_categories_on_eportfolio_id ON eportfolio_categories USING btree (eportfolio_id);


--
-- Name: index_eportfolio_entries_on_eportfolio_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_eportfolio_entries_on_eportfolio_category_id ON eportfolio_entries USING btree (eportfolio_category_id);


--
-- Name: index_eportfolio_entries_on_eportfolio_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_eportfolio_entries_on_eportfolio_id ON eportfolio_entries USING btree (eportfolio_id);


--
-- Name: index_eportfolios_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_eportfolios_on_user_id ON eportfolios USING btree (user_id);


--
-- Name: index_error_reports_on_category; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_error_reports_on_category ON error_reports USING btree (category);


--
-- Name: index_error_reports_on_zendesk_ticket_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_error_reports_on_zendesk_ticket_id ON error_reports USING btree (zendesk_ticket_id);


--
-- Name: index_external_feed_entries_on_external_feed_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_external_feed_entries_on_external_feed_id ON external_feed_entries USING btree (external_feed_id);


--
-- Name: index_external_feed_entries_on_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_external_feed_entries_on_url ON external_feed_entries USING btree (url);


--
-- Name: index_external_feed_entries_on_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_external_feed_entries_on_uuid ON external_feed_entries USING btree (uuid);


--
-- Name: index_external_feeds_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_external_feeds_on_context_id_and_context_type ON external_feeds USING btree (context_id, context_type);


--
-- Name: index_external_integration_keys_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_external_integration_keys_unique ON external_integration_keys USING btree (context_id, context_type, key_type);


--
-- Name: index_favorites_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_on_user_id ON favorites USING btree (user_id);


--
-- Name: index_favorites_unique_user_object; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_unique_user_object ON favorites USING btree (user_id, context_id, context_type);


--
-- Name: index_feature_flags_on_context_and_feature; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_feature_flags_on_context_and_feature ON feature_flags USING btree (context_id, context_type, feature);


--
-- Name: index_folders_on_cloned_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_folders_on_cloned_item_id ON folders USING btree (cloned_item_id);


--
-- Name: index_folders_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_folders_on_context_id_and_context_type ON folders USING btree (context_id, context_type);


--
-- Name: index_folders_on_context_id_and_context_type_for_root_folders; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_folders_on_context_id_and_context_type_for_root_folders ON folders USING btree (context_id, context_type) WHERE ((parent_folder_id IS NULL) AND ((workflow_state)::text <> 'deleted'::text));


--
-- Name: index_folders_on_parent_folder_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_folders_on_parent_folder_id ON folders USING btree (parent_folder_id);


--
-- Name: index_gradebook_uploads_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_gradebook_uploads_on_context_id_and_context_type ON gradebook_uploads USING btree (context_id, context_type);


--
-- Name: index_grading_period_grades_on_enrollment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grading_period_grades_on_enrollment_id ON grading_period_grades USING btree (enrollment_id);


--
-- Name: index_grading_period_grades_on_grading_period_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grading_period_grades_on_grading_period_id ON grading_period_grades USING btree (grading_period_id);


--
-- Name: index_grading_period_groups_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grading_period_groups_on_account_id ON grading_period_groups USING btree (account_id);


--
-- Name: index_grading_period_groups_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grading_period_groups_on_course_id ON grading_period_groups USING btree (course_id);


--
-- Name: index_grading_periods_on_grading_period_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grading_periods_on_grading_period_group_id ON grading_periods USING btree (grading_period_group_id);


--
-- Name: index_grading_standards_on_context_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grading_standards_on_context_code ON grading_standards USING btree (context_code);


--
-- Name: index_grading_standards_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grading_standards_on_context_id_and_context_type ON grading_standards USING btree (context_id, context_type);


--
-- Name: index_group_categories_on_context; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_categories_on_context ON group_categories USING btree (context_id, context_type);


--
-- Name: index_group_categories_on_role; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_categories_on_role ON group_categories USING btree (role);


--
-- Name: index_group_memberships_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_memberships_on_group_id ON group_memberships USING btree (group_id);


--
-- Name: index_group_memberships_on_sis_batch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_memberships_on_sis_batch_id ON group_memberships USING btree (sis_batch_id) WHERE (sis_batch_id IS NOT NULL);


--
-- Name: index_group_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_memberships_on_user_id ON group_memberships USING btree (user_id);


--
-- Name: index_group_memberships_on_workflow_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_memberships_on_workflow_state ON group_memberships USING btree (workflow_state);


--
-- Name: index_groups_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_account_id ON groups USING btree (account_id);


--
-- Name: index_groups_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_context_id_and_context_type ON groups USING btree (context_id, context_type);


--
-- Name: index_groups_on_group_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_group_category_id ON groups USING btree (group_category_id);


--
-- Name: index_groups_on_sis_batch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_sis_batch_id ON groups USING btree (sis_batch_id) WHERE (sis_batch_id IS NOT NULL);


--
-- Name: index_groups_on_sis_source_id_and_root_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_groups_on_sis_source_id_and_root_account_id ON groups USING btree (sis_source_id, root_account_id) WHERE (sis_source_id IS NOT NULL);


--
-- Name: index_groups_on_wiki_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_wiki_id ON groups USING btree (wiki_id) WHERE (wiki_id IS NOT NULL);


--
-- Name: index_icl_individual_projects_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_icl_individual_projects_on_course_id ON icl_individual_projects USING btree (course_id);


--
-- Name: index_icl_project_choices_on_icl_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_icl_project_choices_on_icl_project_id ON icl_project_choices USING btree (icl_project_id);


--
-- Name: index_icl_project_choices_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_icl_project_choices_on_user_id ON icl_project_choices USING btree (user_id);


--
-- Name: index_ignores_on_asset_and_user_id_and_purpose; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_ignores_on_asset_and_user_id_and_purpose ON ignores USING btree (asset_id, asset_type, user_id, purpose);


--
-- Name: index_inbox_items_on_asset_type_and_asset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inbox_items_on_asset_type_and_asset_id ON inbox_items USING btree (asset_type, asset_id);


--
-- Name: index_inbox_items_on_sender; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inbox_items_on_sender ON inbox_items USING btree (sender);


--
-- Name: index_inbox_items_on_sender_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inbox_items_on_sender_id ON inbox_items USING btree (sender_id);


--
-- Name: index_inbox_items_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inbox_items_on_user_id ON inbox_items USING btree (user_id);


--
-- Name: index_inbox_items_on_workflow_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inbox_items_on_workflow_state ON inbox_items USING btree (workflow_state);


--
-- Name: index_learning_outcome_groups_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_learning_outcome_groups_on_context_id_and_context_type ON learning_outcome_groups USING btree (context_id, context_type);


--
-- Name: index_learning_outcome_groups_on_learning_outcome_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_learning_outcome_groups_on_learning_outcome_group_id ON learning_outcome_groups USING btree (learning_outcome_group_id) WHERE (learning_outcome_group_id IS NOT NULL);


--
-- Name: index_learning_outcome_groups_on_vendor_guid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_learning_outcome_groups_on_vendor_guid ON learning_outcome_groups USING btree (vendor_guid);


--
-- Name: index_learning_outcome_results_association; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_learning_outcome_results_association ON learning_outcome_results USING btree (user_id, content_tag_id, association_id, association_type, associated_asset_id, associated_asset_type);


--
-- Name: index_learning_outcomes_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_learning_outcomes_on_context_id_and_context_type ON learning_outcomes USING btree (context_id, context_type);


--
-- Name: index_learning_outcomes_on_vendor_guid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_learning_outcomes_on_vendor_guid ON learning_outcomes USING btree (vendor_guid);


--
-- Name: index_live_assessments; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_live_assessments ON live_assessments_assessments USING btree (context_id, context_type, key);


--
-- Name: index_live_assessments_results_on_assessment_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_live_assessments_results_on_assessment_id_and_user_id ON live_assessments_results USING btree (assessment_id, user_id);


--
-- Name: index_live_assessments_submissions_on_assessment_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_live_assessments_submissions_on_assessment_id_and_user_id ON live_assessments_submissions USING btree (assessment_id, user_id);


--
-- Name: index_lti_message_handlers_on_resource_handler_and_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_lti_message_handlers_on_resource_handler_and_type ON lti_message_handlers USING btree (resource_handler_id, message_type);


--
-- Name: index_lti_product_families_on_root_account_vend_code_prod_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_lti_product_families_on_root_account_vend_code_prod_code ON lti_product_families USING btree (root_account_id, vendor_code, product_code);


--
-- Name: index_lti_resource_handlers_on_tool_proxy_and_type_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_lti_resource_handlers_on_tool_proxy_and_type_code ON lti_resource_handlers USING btree (tool_proxy_id, resource_type_code);


--
-- Name: index_lti_resource_placements_on_placement_and_handler; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_lti_resource_placements_on_placement_and_handler ON lti_resource_placements USING btree (placement, resource_handler_id);


--
-- Name: index_lti_tool_proxies_on_guid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_lti_tool_proxies_on_guid ON lti_tool_proxies USING btree (guid);


--
-- Name: index_lti_tool_proxy_bindings_on_context_and_tool_proxy; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_lti_tool_proxy_bindings_on_context_and_tool_proxy ON lti_tool_proxy_bindings USING btree (context_id, context_type, tool_proxy_id);


--
-- Name: index_lti_tool_settings_on_link_context_and_tool_proxy; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_lti_tool_settings_on_link_context_and_tool_proxy ON lti_tool_settings USING btree (resource_link_id, context_type, context_id, tool_proxy_id);


--
-- Name: index_media_objects_on_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_objects_on_attachment_id ON media_objects USING btree (attachment_id);


--
-- Name: index_media_objects_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_objects_on_context_id_and_context_type ON media_objects USING btree (context_id, context_type);


--
-- Name: index_media_objects_on_media_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_objects_on_media_id ON media_objects USING btree (media_id);


--
-- Name: index_media_objects_on_old_media_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_objects_on_old_media_id ON media_objects USING btree (old_media_id);


--
-- Name: index_messages_on_communication_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_communication_channel_id ON messages USING btree (communication_channel_id);


--
-- Name: index_messages_on_notification_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_notification_id ON messages USING btree (notification_id);


--
-- Name: index_messages_on_root_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_root_account_id ON messages USING btree (root_account_id);


--
-- Name: index_messages_on_sent_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_sent_at ON messages USING btree (sent_at) WHERE (sent_at IS NOT NULL);


--
-- Name: index_messages_user_id_dispatch_at_to_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_user_id_dispatch_at_to_email ON messages USING btree (user_id, to_email, dispatch_at);


--
-- Name: index_migration_issues_on_content_migration_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_migration_issues_on_content_migration_id ON migration_issues USING btree (content_migration_id);


--
-- Name: index_notification_policies_on_cc_and_notification_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_notification_policies_on_cc_and_notification_id ON notification_policies USING btree (communication_channel_id, notification_id);


--
-- Name: index_notification_policies_on_notification_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notification_policies_on_notification_id ON notification_policies USING btree (notification_id);


--
-- Name: index_notifications_unique_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_notifications_unique_on_name ON notifications USING btree (name);


--
-- Name: index_on_aqb_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_on_aqb_on_context_id_and_context_type ON assessment_question_banks USING btree (context_id, context_type);


--
-- Name: index_on_report_snapshots; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_on_report_snapshots ON report_snapshots USING btree (report_type, account_id, created_at);


--
-- Name: index_page_comments_on_page_id_and_page_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_page_comments_on_page_id_and_page_type ON page_comments USING btree (page_id, page_type);


--
-- Name: index_page_comments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_page_comments_on_user_id ON page_comments USING btree (user_id);


--
-- Name: index_page_views_asset_user_access_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_page_views_asset_user_access_id ON page_views USING btree (asset_user_access_id);


--
-- Name: index_page_views_on_account_id_and_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_page_views_on_account_id_and_created_at ON page_views USING btree (account_id, created_at);


--
-- Name: index_page_views_on_context_type_and_context_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_page_views_on_context_type_and_context_id ON page_views USING btree (context_type, context_id);


--
-- Name: index_page_views_on_user_id_and_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_page_views_on_user_id_and_created_at ON page_views USING btree (user_id, created_at);


--
-- Name: index_page_views_summarized_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_page_views_summarized_created_at ON page_views USING btree (summarized, created_at);


--
-- Name: index_plugin_settings_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_plugin_settings_on_name ON plugin_settings USING btree (name);


--
-- Name: index_polling_poll_choices_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polling_poll_choices_on_poll_id ON polling_poll_choices USING btree (poll_id);


--
-- Name: index_polling_poll_sessions_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polling_poll_sessions_on_course_id ON polling_poll_sessions USING btree (course_id);


--
-- Name: index_polling_poll_sessions_on_course_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polling_poll_sessions_on_course_section_id ON polling_poll_sessions USING btree (course_section_id);


--
-- Name: index_polling_poll_sessions_on_poll_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polling_poll_sessions_on_poll_id ON polling_poll_sessions USING btree (poll_id);


--
-- Name: index_polling_poll_submissions_on_poll_choice_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polling_poll_submissions_on_poll_choice_id ON polling_poll_submissions USING btree (poll_choice_id);


--
-- Name: index_polling_poll_submissions_on_poll_session_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polling_poll_submissions_on_poll_session_id ON polling_poll_submissions USING btree (poll_session_id);


--
-- Name: index_polling_poll_submissions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polling_poll_submissions_on_user_id ON polling_poll_submissions USING btree (user_id);


--
-- Name: index_polling_polls_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_polling_polls_on_user_id ON polling_polls USING btree (user_id);


--
-- Name: index_profiles_on_context_type_and_context_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_profiles_on_context_type_and_context_id ON profiles USING btree (context_type, context_id);


--
-- Name: index_profiles_on_root_account_id_and_path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_profiles_on_root_account_id_and_path ON profiles USING btree (root_account_id, path);


--
-- Name: index_progresses_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_progresses_on_context_id_and_context_type ON progresses USING btree (context_id, context_type);


--
-- Name: index_progresses_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_progresses_on_user_id ON progresses USING btree (user_id);


--
-- Name: index_project_courses_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_courses_on_course_id ON project_courses USING btree (course_id);


--
-- Name: index_project_courses_on_icl_project_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_project_courses_on_icl_project_id ON project_courses USING btree (icl_project_id);


--
-- Name: index_pseudonyms_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pseudonyms_on_account_id ON pseudonyms USING btree (account_id);


--
-- Name: index_pseudonyms_on_integration_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_pseudonyms_on_integration_id ON pseudonyms USING btree (integration_id, account_id) WHERE (integration_id IS NOT NULL);


--
-- Name: index_pseudonyms_on_persistence_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pseudonyms_on_persistence_token ON pseudonyms USING btree (persistence_token);


--
-- Name: index_pseudonyms_on_single_access_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pseudonyms_on_single_access_token ON pseudonyms USING btree (single_access_token);


--
-- Name: index_pseudonyms_on_sis_batch_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pseudonyms_on_sis_batch_id ON pseudonyms USING btree (sis_batch_id) WHERE (sis_batch_id IS NOT NULL);


--
-- Name: index_pseudonyms_on_sis_communication_channel_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pseudonyms_on_sis_communication_channel_id ON pseudonyms USING btree (sis_communication_channel_id);


--
-- Name: index_pseudonyms_on_sis_user_id_and_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_pseudonyms_on_sis_user_id_and_account_id ON pseudonyms USING btree (sis_user_id, account_id) WHERE (sis_user_id IS NOT NULL);


--
-- Name: index_pseudonyms_on_unique_id_and_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_pseudonyms_on_unique_id_and_account_id ON pseudonyms USING btree (lower((unique_id)::text), account_id) WHERE ((workflow_state)::text = 'active'::text);


--
-- Name: index_pseudonyms_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pseudonyms_on_user_id ON pseudonyms USING btree (user_id);


--
-- Name: index_qqr_on_qr_id_and_qq_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_qqr_on_qr_id_and_qq_id ON quiz_question_regrades USING btree (quiz_regrade_id, quiz_question_id);


--
-- Name: index_quiz_groups_on_quiz_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quiz_groups_on_quiz_id ON quiz_groups USING btree (quiz_id);


--
-- Name: index_quiz_regrades_on_quiz_id_and_quiz_version; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_quiz_regrades_on_quiz_id_and_quiz_version ON quiz_regrades USING btree (quiz_id, quiz_version);


--
-- Name: index_quiz_statistics_on_quiz_id_and_report_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quiz_statistics_on_quiz_id_and_report_type ON quiz_statistics USING btree (quiz_id, report_type);


--
-- Name: index_quiz_submission_events_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quiz_submission_events_on_created_at ON quiz_submission_events USING btree (created_at);


--
-- Name: index_quiz_submission_snapshots_on_quiz_submission_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quiz_submission_snapshots_on_quiz_submission_id ON quiz_submission_snapshots USING btree (quiz_submission_id);


--
-- Name: index_quiz_submissions_on_quiz_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_quiz_submissions_on_quiz_id_and_user_id ON quiz_submissions USING btree (quiz_id, user_id);


--
-- Name: index_quiz_submissions_on_submission_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quiz_submissions_on_submission_id ON quiz_submissions USING btree (submission_id);


--
-- Name: index_quiz_submissions_on_temporary_user_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quiz_submissions_on_temporary_user_code ON quiz_submissions USING btree (temporary_user_code);


--
-- Name: index_quiz_submissions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quiz_submissions_on_user_id ON quiz_submissions USING btree (user_id);


--
-- Name: index_quizzes_on_assignment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_quizzes_on_assignment_id ON quizzes USING btree (assignment_id);


--
-- Name: index_quizzes_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_quizzes_on_context_id_and_context_type ON quizzes USING btree (context_id, context_type);


--
-- Name: index_role_overrides_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_role_overrides_on_context_id_and_context_type ON role_overrides USING btree (context_id, context_type);


--
-- Name: index_roles_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_on_account_id ON roles USING btree (account_id);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_on_name ON roles USING btree (name);


--
-- Name: index_roles_on_root_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_roles_on_root_account_id ON roles USING btree (root_account_id);


--
-- Name: index_roles_unique_account_name_where_active; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_roles_unique_account_name_where_active ON roles USING btree (account_id, name) WHERE ((workflow_state)::text = 'active'::text);


--
-- Name: index_rubric_assessments_on_artifact_id_and_artifact_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rubric_assessments_on_artifact_id_and_artifact_type ON rubric_assessments USING btree (artifact_id, artifact_type);


--
-- Name: index_rubric_assessments_on_assessor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rubric_assessments_on_assessor_id ON rubric_assessments USING btree (assessor_id);


--
-- Name: index_rubric_assessments_on_rubric_association_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rubric_assessments_on_rubric_association_id ON rubric_assessments USING btree (rubric_association_id);


--
-- Name: index_rubric_assessments_on_rubric_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rubric_assessments_on_rubric_id ON rubric_assessments USING btree (rubric_id);


--
-- Name: index_rubric_assessments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rubric_assessments_on_user_id ON rubric_assessments USING btree (user_id);


--
-- Name: index_rubric_associations_on_aid_and_atype; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rubric_associations_on_aid_and_atype ON rubric_associations USING btree (association_id, association_type);


--
-- Name: index_rubric_associations_on_context_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rubric_associations_on_context_code ON rubric_associations USING btree (context_code);


--
-- Name: index_rubric_associations_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rubric_associations_on_context_id_and_context_type ON rubric_associations USING btree (context_id, context_type);


--
-- Name: index_rubric_associations_on_rubric_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rubric_associations_on_rubric_id ON rubric_associations USING btree (rubric_id);


--
-- Name: index_rubrics_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rubrics_on_context_id_and_context_type ON rubrics USING btree (context_id, context_type);


--
-- Name: index_rubrics_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rubrics_on_user_id ON rubrics USING btree (user_id);


--
-- Name: index_sections_on_integration_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_sections_on_integration_id ON course_sections USING btree (integration_id, root_account_id) WHERE (integration_id IS NOT NULL);


--
-- Name: index_session_persistence_tokens_on_pseudonym_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_session_persistence_tokens_on_pseudonym_id ON session_persistence_tokens USING btree (pseudonym_id);


--
-- Name: index_sessions_on_session_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_session_id ON sessions USING btree (session_id);


--
-- Name: index_sessions_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sessions_on_updated_at ON sessions USING btree (updated_at);


--
-- Name: index_settings_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_name ON settings USING btree (name);


--
-- Name: index_sis_batches_account_id_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sis_batches_account_id_created_at ON sis_batches USING btree (account_id, created_at);


--
-- Name: index_sis_batches_on_batch_mode_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sis_batches_on_batch_mode_term_id ON sis_batches USING btree (batch_mode_term_id) WHERE (batch_mode_term_id IS NOT NULL);


--
-- Name: index_sis_batches_pending_for_accounts; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sis_batches_pending_for_accounts ON sis_batches USING btree (account_id, created_at) WHERE ((workflow_state)::text = 'created'::text);


--
-- Name: index_sis_post_grades_statuses_on_course_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sis_post_grades_statuses_on_course_id ON sis_post_grades_statuses USING btree (course_id);


--
-- Name: index_sis_post_grades_statuses_on_course_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sis_post_grades_statuses_on_course_section_id ON sis_post_grades_statuses USING btree (course_section_id);


--
-- Name: index_sis_post_grades_statuses_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sis_post_grades_statuses_on_user_id ON sis_post_grades_statuses USING btree (user_id);


--
-- Name: index_stream_item_instances_global; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stream_item_instances_global ON stream_item_instances USING btree (user_id, hidden, id, stream_item_id);


--
-- Name: index_stream_item_instances_on_context_type_and_context_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stream_item_instances_on_context_type_and_context_id ON stream_item_instances USING btree (context_type, context_id);


--
-- Name: index_stream_item_instances_on_stream_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stream_item_instances_on_stream_item_id ON stream_item_instances USING btree (stream_item_id);


--
-- Name: index_stream_items_on_asset_type_and_asset_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_stream_items_on_asset_type_and_asset_id ON stream_items USING btree (asset_type, asset_id);


--
-- Name: index_stream_items_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stream_items_on_updated_at ON stream_items USING btree (updated_at);


--
-- Name: index_submission_comment_participants_on_submission_comment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_submission_comment_participants_on_submission_comment_id ON submission_comment_participants USING btree (submission_comment_id);


--
-- Name: index_submission_comment_participants_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_submission_comment_participants_on_user_id ON submission_comment_participants USING btree (user_id);


--
-- Name: index_submission_comments_on_author_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_submission_comments_on_author_id ON submission_comments USING btree (author_id);


--
-- Name: index_submission_comments_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_submission_comments_on_context_id_and_context_type ON submission_comments USING btree (context_id, context_type);


--
-- Name: index_submission_comments_on_recipient_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_submission_comments_on_recipient_id ON submission_comments USING btree (recipient_id);


--
-- Name: index_submission_comments_on_submission_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_submission_comments_on_submission_id ON submission_comments USING btree (submission_id);


--
-- Name: index_submission_versions; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_submission_versions ON submission_versions USING btree (context_id, version_id, user_id, assignment_id) WHERE ((context_type)::text = 'Course'::text);


--
-- Name: index_submissions_on_assignment_id_and_submission_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_submissions_on_assignment_id_and_submission_type ON submissions USING btree (assignment_id, submission_type);


--
-- Name: index_submissions_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_submissions_on_group_id ON submissions USING btree (group_id) WHERE (group_id IS NOT NULL);


--
-- Name: index_submissions_on_submitted_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_submissions_on_submitted_at ON submissions USING btree (submitted_at);


--
-- Name: index_submissions_on_user_id_and_assignment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_submissions_on_user_id_and_assignment_id ON submissions USING btree (user_id, assignment_id);


--
-- Name: index_terms_on_integration_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_terms_on_integration_id ON enrollment_terms USING btree (integration_id, root_account_id) WHERE (integration_id IS NOT NULL);


--
-- Name: index_thumbnails_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_thumbnails_on_parent_id ON thumbnails USING btree (parent_id);


--
-- Name: index_thumbnails_size; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_thumbnails_size ON thumbnails USING btree (parent_id, thumbnail);


--
-- Name: index_topic_participant_on_topic_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_topic_participant_on_topic_id_and_user_id ON discussion_topic_participants USING btree (discussion_topic_id, user_id);


--
-- Name: index_user_account_associations_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_account_associations_on_account_id ON user_account_associations USING btree (account_id);


--
-- Name: index_user_account_associations_on_user_id_and_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_user_account_associations_on_user_id_and_account_id ON user_account_associations USING btree (user_id, account_id);


--
-- Name: index_user_notes_on_user_id_and_workflow_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_notes_on_user_id_and_workflow_state ON user_notes USING btree (user_id, workflow_state);


--
-- Name: index_user_observers_on_observer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_observers_on_observer_id ON user_observers USING btree (observer_id);


--
-- Name: index_user_observers_on_user_id_and_observer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_user_observers_on_user_id_and_observer_id ON user_observers USING btree (user_id, observer_id);


--
-- Name: index_user_services_on_id_and_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_services_on_id_and_type ON user_services USING btree (id, type);


--
-- Name: index_user_services_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_services_on_user_id ON user_services USING btree (user_id);


--
-- Name: index_users_on_avatar_state_and_avatar_image_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_avatar_state_and_avatar_image_updated_at ON users USING btree (avatar_state, avatar_image_updated_at);


--
-- Name: index_users_on_lti_context_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_lti_context_id ON users USING btree (lti_context_id);


--
-- Name: index_users_on_sortable_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_sortable_name ON users USING btree (((lower(replace((sortable_name)::text, '\'::text, '\\'::text)))::bytea));


--
-- Name: index_users_on_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_uuid ON users USING btree (uuid);


--
-- Name: index_versions_on_versionable_object_and_number; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_versions_on_versionable_object_and_number ON versions USING btree (versionable_id, versionable_type, number);


--
-- Name: index_web_conference_participants_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_conference_participants_on_user_id ON web_conference_participants USING btree (user_id);


--
-- Name: index_web_conference_participants_on_web_conference_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_conference_participants_on_web_conference_id ON web_conference_participants USING btree (web_conference_id);


--
-- Name: index_web_conferences_on_context_id_and_context_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_conferences_on_context_id_and_context_type ON web_conferences USING btree (context_id, context_type);


--
-- Name: index_web_conferences_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_web_conferences_on_user_id ON web_conferences USING btree (user_id);


--
-- Name: index_wiki_pages_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wiki_pages_on_user_id ON wiki_pages USING btree (user_id);


--
-- Name: index_wiki_pages_on_wiki_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wiki_pages_on_wiki_id ON wiki_pages USING btree (wiki_id);


--
-- Name: index_zip_file_imports_on_attachment_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_zip_file_imports_on_attachment_id ON zip_file_imports USING btree (attachment_id);


--
-- Name: index_zip_file_imports_on_folder_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_zip_file_imports_on_folder_id ON zip_file_imports USING btree (folder_id);


--
-- Name: media_object_id_locale; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX media_object_id_locale ON media_tracks USING btree (media_object_id, locale);


--
-- Name: qse_2014_11_idx_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX qse_2014_11_idx_on_created_at ON quiz_submission_events_2014_11 USING btree (created_at);


--
-- Name: qse_2014_11_predecessor_locator_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX qse_2014_11_predecessor_locator_idx ON quiz_submission_events_2014_11 USING btree (quiz_submission_id, attempt, created_at);


--
-- Name: qse_2014_12_idx_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX qse_2014_12_idx_on_created_at ON quiz_submission_events_2014_12 USING btree (created_at);


--
-- Name: qse_2014_12_predecessor_locator_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX qse_2014_12_predecessor_locator_idx ON quiz_submission_events_2014_12 USING btree (quiz_submission_id, attempt, created_at);


--
-- Name: qse_2015_1_idx_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX qse_2015_1_idx_on_created_at ON quiz_submission_events_2015_1 USING btree (created_at);


--
-- Name: qse_2015_1_predecessor_locator_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX qse_2015_1_predecessor_locator_idx ON quiz_submission_events_2015_1 USING btree (quiz_submission_id, attempt, created_at);


--
-- Name: qse_2015_2_idx_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX qse_2015_2_idx_on_created_at ON quiz_submission_events_2015_2 USING btree (created_at);


--
-- Name: qse_2015_2_predecessor_locator_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX qse_2015_2_predecessor_locator_idx ON quiz_submission_events_2015_2 USING btree (quiz_submission_id, attempt, created_at);


--
-- Name: qse_2015_3_idx_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX qse_2015_3_idx_on_created_at ON quiz_submission_events_2015_3 USING btree (created_at);


--
-- Name: qse_2015_3_predecessor_locator_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX qse_2015_3_predecessor_locator_idx ON quiz_submission_events_2015_3 USING btree (quiz_submission_id, attempt, created_at);


--
-- Name: question_bank_id_and_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX question_bank_id_and_position ON assessment_questions USING btree (assessment_question_bank_id, "position");


--
-- Name: quiz_questions_quiz_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX quiz_questions_quiz_group_id ON quiz_questions USING btree (quiz_group_id);


--
-- Name: usage_rights_context_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX usage_rights_context_idx ON usage_rights USING btree (context_id, context_type);


--
-- Name: ws_sa; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ws_sa ON delayed_messages USING btree (workflow_state, send_at);


--
-- Name: delayed_jobs_after_delete_row_tr; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delayed_jobs_after_delete_row_tr AFTER DELETE ON delayed_jobs FOR EACH ROW WHEN (((old.strand IS NOT NULL) AND (old.next_in_strand = true))) EXECUTE PROCEDURE delayed_jobs_after_delete_row_tr_fn();


--
-- Name: delayed_jobs_before_insert_row_tr; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delayed_jobs_before_insert_row_tr BEFORE INSERT ON delayed_jobs FOR EACH ROW WHEN ((new.strand IS NOT NULL)) EXECUTE PROCEDURE delayed_jobs_before_insert_row_tr_fn();


--
-- Name: abstract_courses_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY abstract_courses
    ADD CONSTRAINT abstract_courses_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: abstract_courses_enrollment_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY abstract_courses
    ADD CONSTRAINT abstract_courses_enrollment_term_id_fk FOREIGN KEY (enrollment_term_id) REFERENCES enrollment_terms(id);


--
-- Name: abstract_courses_root_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY abstract_courses
    ADD CONSTRAINT abstract_courses_root_account_id_fk FOREIGN KEY (root_account_id) REFERENCES accounts(id);


--
-- Name: abstract_courses_sis_batch_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY abstract_courses
    ADD CONSTRAINT abstract_courses_sis_batch_id_fk FOREIGN KEY (sis_batch_id) REFERENCES sis_batches(id);


--
-- Name: access_tokens_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY access_tokens
    ADD CONSTRAINT access_tokens_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: account_authorization_configs_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_authorization_configs
    ADD CONSTRAINT account_authorization_configs_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: account_notification_roles_account_notification_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_notification_roles
    ADD CONSTRAINT account_notification_roles_account_notification_id_fk FOREIGN KEY (account_notification_id) REFERENCES account_notifications(id);


--
-- Name: account_notification_roles_role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_notification_roles
    ADD CONSTRAINT account_notification_roles_role_id_fk FOREIGN KEY (role_id) REFERENCES roles(id);


--
-- Name: account_notifications_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT account_notifications_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: account_notifications_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_notifications
    ADD CONSTRAINT account_notifications_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: account_reports_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_reports
    ADD CONSTRAINT account_reports_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: account_reports_attachment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_reports
    ADD CONSTRAINT account_reports_attachment_id_fk FOREIGN KEY (attachment_id) REFERENCES attachments(id);


--
-- Name: account_reports_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_reports
    ADD CONSTRAINT account_reports_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: account_users_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT account_users_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: account_users_role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT account_users_role_id_fk FOREIGN KEY (role_id) REFERENCES roles(id);


--
-- Name: account_users_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY account_users
    ADD CONSTRAINT account_users_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: accounts_parent_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_parent_account_id_fk FOREIGN KEY (parent_account_id) REFERENCES accounts(id);


--
-- Name: accounts_root_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_root_account_id_fk FOREIGN KEY (root_account_id) REFERENCES accounts(id);


--
-- Name: accounts_sis_batch_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_sis_batch_id_fk FOREIGN KEY (sis_batch_id) REFERENCES sis_batches(id);


--
-- Name: alert_criteria_alert_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY alert_criteria
    ADD CONSTRAINT alert_criteria_alert_id_fk FOREIGN KEY (alert_id) REFERENCES alerts(id);


--
-- Name: assessment_requests_assessor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessment_requests
    ADD CONSTRAINT assessment_requests_assessor_id_fk FOREIGN KEY (assessor_id) REFERENCES users(id);


--
-- Name: assessment_requests_asset_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessment_requests
    ADD CONSTRAINT assessment_requests_asset_id_fk FOREIGN KEY (asset_id) REFERENCES submissions(id);


--
-- Name: assessment_requests_rubric_association_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessment_requests
    ADD CONSTRAINT assessment_requests_rubric_association_id_fk FOREIGN KEY (rubric_association_id) REFERENCES rubric_associations(id);


--
-- Name: assessment_requests_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessment_requests
    ADD CONSTRAINT assessment_requests_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: assignment_groups_cloned_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignment_groups
    ADD CONSTRAINT assignment_groups_cloned_item_id_fk FOREIGN KEY (cloned_item_id) REFERENCES cloned_items(id);


--
-- Name: assignment_override_students_assignment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignment_override_students
    ADD CONSTRAINT assignment_override_students_assignment_id_fk FOREIGN KEY (assignment_id) REFERENCES assignments(id);


--
-- Name: assignment_override_students_assignment_override_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignment_override_students
    ADD CONSTRAINT assignment_override_students_assignment_override_id_fk FOREIGN KEY (assignment_override_id) REFERENCES assignment_overrides(id);


--
-- Name: assignment_override_students_quiz_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignment_override_students
    ADD CONSTRAINT assignment_override_students_quiz_id_fk FOREIGN KEY (quiz_id) REFERENCES quizzes(id);


--
-- Name: assignment_override_students_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignment_override_students
    ADD CONSTRAINT assignment_override_students_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: assignment_overrides_assignment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignment_overrides
    ADD CONSTRAINT assignment_overrides_assignment_id_fk FOREIGN KEY (assignment_id) REFERENCES assignments(id);


--
-- Name: assignment_overrides_quiz_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignment_overrides
    ADD CONSTRAINT assignment_overrides_quiz_id_fk FOREIGN KEY (quiz_id) REFERENCES quizzes(id);


--
-- Name: assignments_cloned_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_cloned_item_id_fk FOREIGN KEY (cloned_item_id) REFERENCES cloned_items(id);


--
-- Name: assignments_group_category_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_group_category_id_fk FOREIGN KEY (group_category_id) REFERENCES group_categories(id);


--
-- Name: attachments_replacement_attachment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_replacement_attachment_id_fk FOREIGN KEY (replacement_attachment_id) REFERENCES attachments(id);


--
-- Name: attachments_root_attachment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_root_attachment_id_fk FOREIGN KEY (root_attachment_id) REFERENCES attachments(id);


--
-- Name: attachments_usage_rights_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_usage_rights_id_fk FOREIGN KEY (usage_rights_id) REFERENCES usage_rights(id);


--
-- Name: calendar_events_cloned_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY calendar_events
    ADD CONSTRAINT calendar_events_cloned_item_id_fk FOREIGN KEY (cloned_item_id) REFERENCES cloned_items(id);


--
-- Name: calendar_events_parent_calendar_event_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY calendar_events
    ADD CONSTRAINT calendar_events_parent_calendar_event_id_fk FOREIGN KEY (parent_calendar_event_id) REFERENCES calendar_events(id);


--
-- Name: calendar_events_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY calendar_events
    ADD CONSTRAINT calendar_events_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: canvadocs_attachment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY canvadocs
    ADD CONSTRAINT canvadocs_attachment_id_fk FOREIGN KEY (attachment_id) REFERENCES attachments(id);


--
-- Name: collaborations_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collaborations
    ADD CONSTRAINT collaborations_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: collaborators_collaboration_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collaborators
    ADD CONSTRAINT collaborators_collaboration_id_fk FOREIGN KEY (collaboration_id) REFERENCES collaborations(id);


--
-- Name: collaborators_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collaborators
    ADD CONSTRAINT collaborators_group_id_fk FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: collaborators_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collaborators
    ADD CONSTRAINT collaborators_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: communication_channels_access_token_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY communication_channels
    ADD CONSTRAINT communication_channels_access_token_id_fk FOREIGN KEY (access_token_id) REFERENCES access_tokens(id);


--
-- Name: communication_channels_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY communication_channels
    ADD CONSTRAINT communication_channels_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: content_exports_attachment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_exports
    ADD CONSTRAINT content_exports_attachment_id_fk FOREIGN KEY (attachment_id) REFERENCES attachments(id);


--
-- Name: content_exports_content_migration_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_exports
    ADD CONSTRAINT content_exports_content_migration_id_fk FOREIGN KEY (content_migration_id) REFERENCES content_migrations(id);


--
-- Name: content_exports_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_exports
    ADD CONSTRAINT content_exports_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: content_migrations_attachment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_migrations
    ADD CONSTRAINT content_migrations_attachment_id_fk FOREIGN KEY (attachment_id) REFERENCES attachments(id);


--
-- Name: content_migrations_exported_attachment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_migrations
    ADD CONSTRAINT content_migrations_exported_attachment_id_fk FOREIGN KEY (exported_attachment_id) REFERENCES attachments(id);


--
-- Name: content_migrations_overview_attachment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_migrations
    ADD CONSTRAINT content_migrations_overview_attachment_id_fk FOREIGN KEY (overview_attachment_id) REFERENCES attachments(id);


--
-- Name: content_migrations_source_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_migrations
    ADD CONSTRAINT content_migrations_source_course_id_fk FOREIGN KEY (source_course_id) REFERENCES courses(id);


--
-- Name: content_migrations_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_migrations
    ADD CONSTRAINT content_migrations_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: content_participations_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_participations
    ADD CONSTRAINT content_participations_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: content_tags_cloned_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_tags
    ADD CONSTRAINT content_tags_cloned_item_id_fk FOREIGN KEY (cloned_item_id) REFERENCES cloned_items(id);


--
-- Name: content_tags_context_module_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_tags
    ADD CONSTRAINT content_tags_context_module_id_fk FOREIGN KEY (context_module_id) REFERENCES context_modules(id);


--
-- Name: content_tags_learning_outcome_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY content_tags
    ADD CONSTRAINT content_tags_learning_outcome_id_fk FOREIGN KEY (learning_outcome_id) REFERENCES learning_outcomes(id);


--
-- Name: context_external_tool_placements_context_external_tool_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY context_external_tool_placements
    ADD CONSTRAINT context_external_tool_placements_context_external_tool_id_fk FOREIGN KEY (context_external_tool_id) REFERENCES context_external_tools(id);


--
-- Name: context_external_tools_cloned_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY context_external_tools
    ADD CONSTRAINT context_external_tools_cloned_item_id_fk FOREIGN KEY (cloned_item_id) REFERENCES cloned_items(id);


--
-- Name: context_module_progressions_context_module_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY context_module_progressions
    ADD CONSTRAINT context_module_progressions_context_module_id_fk FOREIGN KEY (context_module_id) REFERENCES context_modules(id);


--
-- Name: context_module_progressions_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY context_module_progressions
    ADD CONSTRAINT context_module_progressions_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: context_modules_cloned_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY context_modules
    ADD CONSTRAINT context_modules_cloned_item_id_fk FOREIGN KEY (cloned_item_id) REFERENCES cloned_items(id);


--
-- Name: conversation_batches_root_conversation_message_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY conversation_batches
    ADD CONSTRAINT conversation_batches_root_conversation_message_id_fk FOREIGN KEY (root_conversation_message_id) REFERENCES conversation_messages(id);


--
-- Name: conversation_batches_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY conversation_batches
    ADD CONSTRAINT conversation_batches_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: conversation_message_participants_conversation_message_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY conversation_message_participants
    ADD CONSTRAINT conversation_message_participants_conversation_message_id_fk FOREIGN KEY (conversation_message_id) REFERENCES conversation_messages(id);


--
-- Name: conversation_messages_conversation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY conversation_messages
    ADD CONSTRAINT conversation_messages_conversation_id_fk FOREIGN KEY (conversation_id) REFERENCES conversations(id);


--
-- Name: course_account_associations_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_account_associations
    ADD CONSTRAINT course_account_associations_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: course_account_associations_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_account_associations
    ADD CONSTRAINT course_account_associations_course_id_fk FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: course_account_associations_course_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_account_associations
    ADD CONSTRAINT course_account_associations_course_section_id_fk FOREIGN KEY (course_section_id) REFERENCES course_sections(id);


--
-- Name: course_imports_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_imports
    ADD CONSTRAINT course_imports_course_id_fk FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: course_imports_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_imports
    ADD CONSTRAINT course_imports_source_id_fk FOREIGN KEY (source_id) REFERENCES courses(id);


--
-- Name: course_sections_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_sections
    ADD CONSTRAINT course_sections_course_id_fk FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: course_sections_enrollment_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_sections
    ADD CONSTRAINT course_sections_enrollment_term_id_fk FOREIGN KEY (enrollment_term_id) REFERENCES enrollment_terms(id);


--
-- Name: course_sections_nonxlist_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_sections
    ADD CONSTRAINT course_sections_nonxlist_course_id_fk FOREIGN KEY (nonxlist_course_id) REFERENCES courses(id);


--
-- Name: course_sections_root_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_sections
    ADD CONSTRAINT course_sections_root_account_id_fk FOREIGN KEY (root_account_id) REFERENCES accounts(id);


--
-- Name: course_sections_sis_batch_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY course_sections
    ADD CONSTRAINT course_sections_sis_batch_id_fk FOREIGN KEY (sis_batch_id) REFERENCES sis_batches(id);


--
-- Name: courses_abstract_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_abstract_course_id_fk FOREIGN KEY (abstract_course_id) REFERENCES abstract_courses(id);


--
-- Name: courses_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: courses_enrollment_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_enrollment_term_id_fk FOREIGN KEY (enrollment_term_id) REFERENCES enrollment_terms(id);


--
-- Name: courses_root_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_root_account_id_fk FOREIGN KEY (root_account_id) REFERENCES accounts(id);


--
-- Name: courses_sis_batch_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_sis_batch_id_fk FOREIGN KEY (sis_batch_id) REFERENCES sis_batches(id);


--
-- Name: courses_template_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_template_course_id_fk FOREIGN KEY (template_course_id) REFERENCES courses(id);


--
-- Name: courses_wiki_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_wiki_id_fk FOREIGN KEY (wiki_id) REFERENCES wikis(id);


--
-- Name: custom_gradebook_column_data_custom_gradebook_column_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_gradebook_column_data
    ADD CONSTRAINT custom_gradebook_column_data_custom_gradebook_column_id_fk FOREIGN KEY (custom_gradebook_column_id) REFERENCES custom_gradebook_columns(id);


--
-- Name: custom_gradebook_column_data_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_gradebook_column_data
    ADD CONSTRAINT custom_gradebook_column_data_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: custom_gradebook_columns_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_gradebook_columns
    ADD CONSTRAINT custom_gradebook_columns_course_id_fk FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: data_exports_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY data_exports
    ADD CONSTRAINT data_exports_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: delayed_messages_communication_channel_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_messages
    ADD CONSTRAINT delayed_messages_communication_channel_id_fk FOREIGN KEY (communication_channel_id) REFERENCES communication_channels(id);


--
-- Name: delayed_messages_notification_policy_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_messages
    ADD CONSTRAINT delayed_messages_notification_policy_id_fk FOREIGN KEY (notification_policy_id) REFERENCES notification_policies(id);


--
-- Name: discussion_entries_attachment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_entries
    ADD CONSTRAINT discussion_entries_attachment_id_fk FOREIGN KEY (attachment_id) REFERENCES attachments(id);


--
-- Name: discussion_entries_discussion_topic_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_entries
    ADD CONSTRAINT discussion_entries_discussion_topic_id_fk FOREIGN KEY (discussion_topic_id) REFERENCES discussion_topics(id);


--
-- Name: discussion_entries_editor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_entries
    ADD CONSTRAINT discussion_entries_editor_id_fk FOREIGN KEY (editor_id) REFERENCES users(id);


--
-- Name: discussion_entries_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_entries
    ADD CONSTRAINT discussion_entries_parent_id_fk FOREIGN KEY (parent_id) REFERENCES discussion_entries(id);


--
-- Name: discussion_entries_root_entry_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_entries
    ADD CONSTRAINT discussion_entries_root_entry_id_fk FOREIGN KEY (root_entry_id) REFERENCES discussion_entries(id);


--
-- Name: discussion_entries_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_entries
    ADD CONSTRAINT discussion_entries_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: discussion_entry_participants_discussion_entry_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_entry_participants
    ADD CONSTRAINT discussion_entry_participants_discussion_entry_id_fk FOREIGN KEY (discussion_entry_id) REFERENCES discussion_entries(id);


--
-- Name: discussion_entry_participants_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_entry_participants
    ADD CONSTRAINT discussion_entry_participants_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: discussion_topic_materialized_views_discussion_topic_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topic_materialized_views
    ADD CONSTRAINT discussion_topic_materialized_views_discussion_topic_id_fk FOREIGN KEY (discussion_topic_id) REFERENCES discussion_topics(id);


--
-- Name: discussion_topic_participants_discussion_topic_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topic_participants
    ADD CONSTRAINT discussion_topic_participants_discussion_topic_id_fk FOREIGN KEY (discussion_topic_id) REFERENCES discussion_topics(id);


--
-- Name: discussion_topic_participants_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topic_participants
    ADD CONSTRAINT discussion_topic_participants_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: discussion_topics_assignment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topics
    ADD CONSTRAINT discussion_topics_assignment_id_fk FOREIGN KEY (assignment_id) REFERENCES assignments(id);


--
-- Name: discussion_topics_attachment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topics
    ADD CONSTRAINT discussion_topics_attachment_id_fk FOREIGN KEY (attachment_id) REFERENCES attachments(id);


--
-- Name: discussion_topics_cloned_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topics
    ADD CONSTRAINT discussion_topics_cloned_item_id_fk FOREIGN KEY (cloned_item_id) REFERENCES cloned_items(id);


--
-- Name: discussion_topics_editor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topics
    ADD CONSTRAINT discussion_topics_editor_id_fk FOREIGN KEY (editor_id) REFERENCES users(id);


--
-- Name: discussion_topics_external_feed_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topics
    ADD CONSTRAINT discussion_topics_external_feed_id_fk FOREIGN KEY (external_feed_id) REFERENCES external_feeds(id);


--
-- Name: discussion_topics_group_category_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topics
    ADD CONSTRAINT discussion_topics_group_category_id_fk FOREIGN KEY (group_category_id) REFERENCES group_categories(id);


--
-- Name: discussion_topics_old_assignment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topics
    ADD CONSTRAINT discussion_topics_old_assignment_id_fk FOREIGN KEY (old_assignment_id) REFERENCES assignments(id);


--
-- Name: discussion_topics_root_topic_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topics
    ADD CONSTRAINT discussion_topics_root_topic_id_fk FOREIGN KEY (root_topic_id) REFERENCES discussion_topics(id);


--
-- Name: discussion_topics_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY discussion_topics
    ADD CONSTRAINT discussion_topics_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: enrollment_dates_overrides_enrollment_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollment_dates_overrides
    ADD CONSTRAINT enrollment_dates_overrides_enrollment_term_id_fk FOREIGN KEY (enrollment_term_id) REFERENCES enrollment_terms(id);


--
-- Name: enrollment_terms_root_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollment_terms
    ADD CONSTRAINT enrollment_terms_root_account_id_fk FOREIGN KEY (root_account_id) REFERENCES accounts(id);


--
-- Name: enrollment_terms_sis_batch_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollment_terms
    ADD CONSTRAINT enrollment_terms_sis_batch_id_fk FOREIGN KEY (sis_batch_id) REFERENCES sis_batches(id);


--
-- Name: enrollments_associated_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollments
    ADD CONSTRAINT enrollments_associated_user_id_fk FOREIGN KEY (associated_user_id) REFERENCES users(id);


--
-- Name: enrollments_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollments
    ADD CONSTRAINT enrollments_course_id_fk FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: enrollments_course_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollments
    ADD CONSTRAINT enrollments_course_section_id_fk FOREIGN KEY (course_section_id) REFERENCES course_sections(id);


--
-- Name: enrollments_role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollments
    ADD CONSTRAINT enrollments_role_id_fk FOREIGN KEY (role_id) REFERENCES roles(id);


--
-- Name: enrollments_root_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollments
    ADD CONSTRAINT enrollments_root_account_id_fk FOREIGN KEY (root_account_id) REFERENCES accounts(id);


--
-- Name: enrollments_sis_batch_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollments
    ADD CONSTRAINT enrollments_sis_batch_id_fk FOREIGN KEY (sis_batch_id) REFERENCES sis_batches(id);


--
-- Name: enrollments_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY enrollments
    ADD CONSTRAINT enrollments_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: eportfolio_categories_eportfolio_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eportfolio_categories
    ADD CONSTRAINT eportfolio_categories_eportfolio_id_fk FOREIGN KEY (eportfolio_id) REFERENCES eportfolios(id);


--
-- Name: eportfolio_entries_eportfolio_category_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eportfolio_entries
    ADD CONSTRAINT eportfolio_entries_eportfolio_category_id_fk FOREIGN KEY (eportfolio_category_id) REFERENCES eportfolio_categories(id);


--
-- Name: eportfolio_entries_eportfolio_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eportfolio_entries
    ADD CONSTRAINT eportfolio_entries_eportfolio_id_fk FOREIGN KEY (eportfolio_id) REFERENCES eportfolios(id);


--
-- Name: eportfolios_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY eportfolios
    ADD CONSTRAINT eportfolios_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: external_feed_entries_external_feed_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY external_feed_entries
    ADD CONSTRAINT external_feed_entries_external_feed_id_fk FOREIGN KEY (external_feed_id) REFERENCES external_feeds(id);


--
-- Name: external_feed_entries_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY external_feed_entries
    ADD CONSTRAINT external_feed_entries_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: external_feeds_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY external_feeds
    ADD CONSTRAINT external_feeds_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: favorites_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: folders_cloned_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY folders
    ADD CONSTRAINT folders_cloned_item_id_fk FOREIGN KEY (cloned_item_id) REFERENCES cloned_items(id);


--
-- Name: folders_parent_folder_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY folders
    ADD CONSTRAINT folders_parent_folder_id_fk FOREIGN KEY (parent_folder_id) REFERENCES folders(id);


--
-- Name: grading_period_grades_enrollment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grading_period_grades
    ADD CONSTRAINT grading_period_grades_enrollment_id_fk FOREIGN KEY (enrollment_id) REFERENCES enrollments(id);


--
-- Name: grading_period_grades_grading_period_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grading_period_grades
    ADD CONSTRAINT grading_period_grades_grading_period_id_fk FOREIGN KEY (grading_period_id) REFERENCES grading_periods(id);


--
-- Name: grading_period_groups_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grading_period_groups
    ADD CONSTRAINT grading_period_groups_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: grading_period_groups_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grading_period_groups
    ADD CONSTRAINT grading_period_groups_course_id_fk FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: grading_periods_grading_period_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grading_periods
    ADD CONSTRAINT grading_periods_grading_period_group_id_fk FOREIGN KEY (grading_period_group_id) REFERENCES grading_period_groups(id);


--
-- Name: grading_standards_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grading_standards
    ADD CONSTRAINT grading_standards_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: group_memberships_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_memberships
    ADD CONSTRAINT group_memberships_group_id_fk FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: group_memberships_sis_batch_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_memberships
    ADD CONSTRAINT group_memberships_sis_batch_id_fk FOREIGN KEY (sis_batch_id) REFERENCES sis_batches(id);


--
-- Name: group_memberships_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_memberships
    ADD CONSTRAINT group_memberships_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: groups_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: groups_group_category_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_group_category_id_fk FOREIGN KEY (group_category_id) REFERENCES group_categories(id);


--
-- Name: groups_leader_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_leader_id_fk FOREIGN KEY (leader_id) REFERENCES users(id);


--
-- Name: groups_root_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_root_account_id_fk FOREIGN KEY (root_account_id) REFERENCES accounts(id);


--
-- Name: groups_sis_batch_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_sis_batch_id_fk FOREIGN KEY (sis_batch_id) REFERENCES sis_batches(id);


--
-- Name: groups_wiki_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_wiki_id_fk FOREIGN KEY (wiki_id) REFERENCES wikis(id);


--
-- Name: ignores_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ignores
    ADD CONSTRAINT ignores_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: learning_outcome_groups_learning_outcome_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY learning_outcome_groups
    ADD CONSTRAINT learning_outcome_groups_learning_outcome_group_id_fk FOREIGN KEY (learning_outcome_group_id) REFERENCES learning_outcome_groups(id);


--
-- Name: learning_outcome_groups_root_learning_outcome_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY learning_outcome_groups
    ADD CONSTRAINT learning_outcome_groups_root_learning_outcome_group_id_fk FOREIGN KEY (root_learning_outcome_group_id) REFERENCES learning_outcome_groups(id);


--
-- Name: learning_outcome_results_content_tag_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY learning_outcome_results
    ADD CONSTRAINT learning_outcome_results_content_tag_id_fk FOREIGN KEY (content_tag_id) REFERENCES content_tags(id);


--
-- Name: learning_outcome_results_learning_outcome_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY learning_outcome_results
    ADD CONSTRAINT learning_outcome_results_learning_outcome_id_fk FOREIGN KEY (learning_outcome_id) REFERENCES learning_outcomes(id);


--
-- Name: learning_outcome_results_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY learning_outcome_results
    ADD CONSTRAINT learning_outcome_results_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: live_assessments_results_assessment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY live_assessments_results
    ADD CONSTRAINT live_assessments_results_assessment_id_fk FOREIGN KEY (assessment_id) REFERENCES live_assessments_assessments(id);


--
-- Name: live_assessments_results_assessor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY live_assessments_results
    ADD CONSTRAINT live_assessments_results_assessor_id_fk FOREIGN KEY (assessor_id) REFERENCES users(id);


--
-- Name: live_assessments_submissions_assessment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY live_assessments_submissions
    ADD CONSTRAINT live_assessments_submissions_assessment_id_fk FOREIGN KEY (assessment_id) REFERENCES live_assessments_assessments(id);


--
-- Name: live_assessments_submissions_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY live_assessments_submissions
    ADD CONSTRAINT live_assessments_submissions_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: lti_message_handlers_resource_handler_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_message_handlers
    ADD CONSTRAINT lti_message_handlers_resource_handler_id_fk FOREIGN KEY (resource_handler_id) REFERENCES lti_resource_handlers(id);


--
-- Name: lti_product_families_root_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_product_families
    ADD CONSTRAINT lti_product_families_root_account_id_fk FOREIGN KEY (root_account_id) REFERENCES accounts(id);


--
-- Name: lti_resource_handlers_tool_proxy_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_resource_handlers
    ADD CONSTRAINT lti_resource_handlers_tool_proxy_id_fk FOREIGN KEY (tool_proxy_id) REFERENCES lti_tool_proxies(id);


--
-- Name: lti_resource_placements_resource_handler_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_resource_placements
    ADD CONSTRAINT lti_resource_placements_resource_handler_id_fk FOREIGN KEY (resource_handler_id) REFERENCES lti_resource_handlers(id);


--
-- Name: lti_tool_proxies_product_family_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_tool_proxies
    ADD CONSTRAINT lti_tool_proxies_product_family_id_fk FOREIGN KEY (product_family_id) REFERENCES lti_product_families(id);


--
-- Name: lti_tool_proxy_bindings_tool_proxy_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lti_tool_proxy_bindings
    ADD CONSTRAINT lti_tool_proxy_bindings_tool_proxy_id_fk FOREIGN KEY (tool_proxy_id) REFERENCES lti_tool_proxies(id);


--
-- Name: media_objects_root_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_objects
    ADD CONSTRAINT media_objects_root_account_id_fk FOREIGN KEY (root_account_id) REFERENCES accounts(id);


--
-- Name: media_objects_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_objects
    ADD CONSTRAINT media_objects_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: migration_issues_content_migration_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY migration_issues
    ADD CONSTRAINT migration_issues_content_migration_id_fk FOREIGN KEY (content_migration_id) REFERENCES content_migrations(id);


--
-- Name: notification_policies_communication_channel_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notification_policies
    ADD CONSTRAINT notification_policies_communication_channel_id_fk FOREIGN KEY (communication_channel_id) REFERENCES communication_channels(id);


--
-- Name: oauth_requests_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_requests
    ADD CONSTRAINT oauth_requests_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: page_comments_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY page_comments
    ADD CONSTRAINT page_comments_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: page_views_real_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY page_views
    ADD CONSTRAINT page_views_real_user_id_fk FOREIGN KEY (real_user_id) REFERENCES users(id);


--
-- Name: page_views_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY page_views
    ADD CONSTRAINT page_views_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: polling_poll_choices_poll_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_poll_choices
    ADD CONSTRAINT polling_poll_choices_poll_id_fk FOREIGN KEY (poll_id) REFERENCES polling_polls(id);


--
-- Name: polling_poll_sessions_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_poll_sessions
    ADD CONSTRAINT polling_poll_sessions_course_id_fk FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: polling_poll_sessions_course_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_poll_sessions
    ADD CONSTRAINT polling_poll_sessions_course_section_id_fk FOREIGN KEY (course_section_id) REFERENCES course_sections(id);


--
-- Name: polling_poll_submissions_poll_choice_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_poll_submissions
    ADD CONSTRAINT polling_poll_submissions_poll_choice_id_fk FOREIGN KEY (poll_choice_id) REFERENCES polling_poll_choices(id);


--
-- Name: polling_poll_submissions_poll_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_poll_submissions
    ADD CONSTRAINT polling_poll_submissions_poll_id_fk FOREIGN KEY (poll_id) REFERENCES polling_polls(id);


--
-- Name: polling_poll_submissions_poll_session_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_poll_submissions
    ADD CONSTRAINT polling_poll_submissions_poll_session_id_fk FOREIGN KEY (poll_session_id) REFERENCES polling_poll_sessions(id);


--
-- Name: polling_poll_submissions_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_poll_submissions
    ADD CONSTRAINT polling_poll_submissions_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: polling_polls_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY polling_polls
    ADD CONSTRAINT polling_polls_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: profiles_root_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_root_account_id_fk FOREIGN KEY (root_account_id) REFERENCES accounts(id);


--
-- Name: pseudonyms_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pseudonyms
    ADD CONSTRAINT pseudonyms_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: pseudonyms_sis_batch_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pseudonyms
    ADD CONSTRAINT pseudonyms_sis_batch_id_fk FOREIGN KEY (sis_batch_id) REFERENCES sis_batches(id);


--
-- Name: pseudonyms_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pseudonyms
    ADD CONSTRAINT pseudonyms_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: quiz_question_regrades_quiz_question_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_question_regrades
    ADD CONSTRAINT quiz_question_regrades_quiz_question_id_fk FOREIGN KEY (quiz_question_id) REFERENCES quiz_questions(id);


--
-- Name: quiz_question_regrades_quiz_regrade_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_question_regrades
    ADD CONSTRAINT quiz_question_regrades_quiz_regrade_id_fk FOREIGN KEY (quiz_regrade_id) REFERENCES quiz_regrades(id);


--
-- Name: quiz_regrade_runs_quiz_regrade_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_regrade_runs
    ADD CONSTRAINT quiz_regrade_runs_quiz_regrade_id_fk FOREIGN KEY (quiz_regrade_id) REFERENCES quiz_regrades(id);


--
-- Name: quiz_regrades_quiz_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_regrades
    ADD CONSTRAINT quiz_regrades_quiz_id_fk FOREIGN KEY (quiz_id) REFERENCES quizzes(id);


--
-- Name: quiz_regrades_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_regrades
    ADD CONSTRAINT quiz_regrades_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: quiz_statistics_quiz_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_statistics
    ADD CONSTRAINT quiz_statistics_quiz_id_fk FOREIGN KEY (quiz_id) REFERENCES quizzes(id);


--
-- Name: quiz_submission_events_2014_11_quiz_submission_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_events_2014_11
    ADD CONSTRAINT quiz_submission_events_2014_11_quiz_submission_id_fk FOREIGN KEY (quiz_submission_id) REFERENCES quiz_submissions(id);


--
-- Name: quiz_submission_events_2014_12_quiz_submission_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_events_2014_12
    ADD CONSTRAINT quiz_submission_events_2014_12_quiz_submission_id_fk FOREIGN KEY (quiz_submission_id) REFERENCES quiz_submissions(id);


--
-- Name: quiz_submission_events_2015_1_quiz_submission_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_events_2015_1
    ADD CONSTRAINT quiz_submission_events_2015_1_quiz_submission_id_fk FOREIGN KEY (quiz_submission_id) REFERENCES quiz_submissions(id);


--
-- Name: quiz_submission_events_2015_2_quiz_submission_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_events_2015_2
    ADD CONSTRAINT quiz_submission_events_2015_2_quiz_submission_id_fk FOREIGN KEY (quiz_submission_id) REFERENCES quiz_submissions(id);


--
-- Name: quiz_submission_events_2015_3_quiz_submission_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_events_2015_3
    ADD CONSTRAINT quiz_submission_events_2015_3_quiz_submission_id_fk FOREIGN KEY (quiz_submission_id) REFERENCES quiz_submissions(id);


--
-- Name: quiz_submission_events_quiz_submission_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submission_events
    ADD CONSTRAINT quiz_submission_events_quiz_submission_id_fk FOREIGN KEY (quiz_submission_id) REFERENCES quiz_submissions(id);


--
-- Name: quiz_submissions_quiz_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submissions
    ADD CONSTRAINT quiz_submissions_quiz_id_fk FOREIGN KEY (quiz_id) REFERENCES quizzes(id);


--
-- Name: quiz_submissions_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quiz_submissions
    ADD CONSTRAINT quiz_submissions_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: quizzes_assignment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_assignment_id_fk FOREIGN KEY (assignment_id) REFERENCES assignments(id);


--
-- Name: quizzes_cloned_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY quizzes
    ADD CONSTRAINT quizzes_cloned_item_id_fk FOREIGN KEY (cloned_item_id) REFERENCES cloned_items(id);


--
-- Name: report_snapshots_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY report_snapshots
    ADD CONSTRAINT report_snapshots_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: role_overrides_context_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY role_overrides
    ADD CONSTRAINT role_overrides_context_id_fk FOREIGN KEY (context_id) REFERENCES accounts(id);


--
-- Name: role_overrides_role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY role_overrides
    ADD CONSTRAINT role_overrides_role_id_fk FOREIGN KEY (role_id) REFERENCES roles(id);


--
-- Name: roles_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: roles_root_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_root_account_id_fk FOREIGN KEY (root_account_id) REFERENCES accounts(id);


--
-- Name: rubric_assessments_assessor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rubric_assessments
    ADD CONSTRAINT rubric_assessments_assessor_id_fk FOREIGN KEY (assessor_id) REFERENCES users(id);


--
-- Name: rubric_assessments_rubric_association_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rubric_assessments
    ADD CONSTRAINT rubric_assessments_rubric_association_id_fk FOREIGN KEY (rubric_association_id) REFERENCES rubric_associations(id);


--
-- Name: rubric_assessments_rubric_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rubric_assessments
    ADD CONSTRAINT rubric_assessments_rubric_id_fk FOREIGN KEY (rubric_id) REFERENCES rubrics(id);


--
-- Name: rubric_assessments_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rubric_assessments
    ADD CONSTRAINT rubric_assessments_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: rubric_associations_rubric_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rubric_associations
    ADD CONSTRAINT rubric_associations_rubric_id_fk FOREIGN KEY (rubric_id) REFERENCES rubrics(id);


--
-- Name: rubrics_rubric_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rubrics
    ADD CONSTRAINT rubrics_rubric_id_fk FOREIGN KEY (rubric_id) REFERENCES rubrics(id);


--
-- Name: rubrics_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rubrics
    ADD CONSTRAINT rubrics_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: session_persistence_tokens_pseudonym_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY session_persistence_tokens
    ADD CONSTRAINT session_persistence_tokens_pseudonym_id_fk FOREIGN KEY (pseudonym_id) REFERENCES pseudonyms(id);


--
-- Name: sis_batches_batch_mode_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sis_batches
    ADD CONSTRAINT sis_batches_batch_mode_term_id_fk FOREIGN KEY (batch_mode_term_id) REFERENCES enrollment_terms(id);


--
-- Name: sis_batches_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sis_batches
    ADD CONSTRAINT sis_batches_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: sis_post_grades_statuses_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sis_post_grades_statuses
    ADD CONSTRAINT sis_post_grades_statuses_course_id_fk FOREIGN KEY (course_id) REFERENCES courses(id);


--
-- Name: sis_post_grades_statuses_course_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sis_post_grades_statuses
    ADD CONSTRAINT sis_post_grades_statuses_course_section_id_fk FOREIGN KEY (course_section_id) REFERENCES course_sections(id);


--
-- Name: sis_post_grades_statuses_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sis_post_grades_statuses
    ADD CONSTRAINT sis_post_grades_statuses_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: stream_item_instances_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY stream_item_instances
    ADD CONSTRAINT stream_item_instances_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: submission_comment_participants_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submission_comment_participants
    ADD CONSTRAINT submission_comment_participants_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: submission_comments_author_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submission_comments
    ADD CONSTRAINT submission_comments_author_id_fk FOREIGN KEY (author_id) REFERENCES users(id);


--
-- Name: submission_comments_recipient_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submission_comments
    ADD CONSTRAINT submission_comments_recipient_id_fk FOREIGN KEY (recipient_id) REFERENCES users(id);


--
-- Name: submission_comments_submission_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submission_comments
    ADD CONSTRAINT submission_comments_submission_id_fk FOREIGN KEY (submission_id) REFERENCES submissions(id);


--
-- Name: submissions_assignment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submissions
    ADD CONSTRAINT submissions_assignment_id_fk FOREIGN KEY (assignment_id) REFERENCES assignments(id);


--
-- Name: submissions_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submissions
    ADD CONSTRAINT submissions_group_id_fk FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: submissions_media_object_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submissions
    ADD CONSTRAINT submissions_media_object_id_fk FOREIGN KEY (media_object_id) REFERENCES media_objects(id);


--
-- Name: submissions_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submissions
    ADD CONSTRAINT submissions_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_account_associations_account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_account_associations
    ADD CONSTRAINT user_account_associations_account_id_fk FOREIGN KEY (account_id) REFERENCES accounts(id);


--
-- Name: user_account_associations_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_account_associations
    ADD CONSTRAINT user_account_associations_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_notes_created_by_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_notes
    ADD CONSTRAINT user_notes_created_by_id_fk FOREIGN KEY (created_by_id) REFERENCES users(id);


--
-- Name: user_notes_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_notes
    ADD CONSTRAINT user_notes_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_observers_observer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_observers
    ADD CONSTRAINT user_observers_observer_id_fk FOREIGN KEY (observer_id) REFERENCES users(id);


--
-- Name: user_observers_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_observers
    ADD CONSTRAINT user_observers_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_profile_links_user_profile_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_profile_links
    ADD CONSTRAINT user_profile_links_user_profile_id_fk FOREIGN KEY (user_profile_id) REFERENCES user_profiles(id);


--
-- Name: user_profiles_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_profiles
    ADD CONSTRAINT user_profiles_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: user_services_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_services
    ADD CONSTRAINT user_services_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: web_conference_participants_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_conference_participants
    ADD CONSTRAINT web_conference_participants_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: web_conference_participants_web_conference_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_conference_participants
    ADD CONSTRAINT web_conference_participants_web_conference_id_fk FOREIGN KEY (web_conference_id) REFERENCES web_conferences(id);


--
-- Name: web_conferences_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_conferences
    ADD CONSTRAINT web_conferences_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: wiki_pages_cloned_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY wiki_pages
    ADD CONSTRAINT wiki_pages_cloned_item_id_fk FOREIGN KEY (cloned_item_id) REFERENCES cloned_items(id);


--
-- Name: wiki_pages_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY wiki_pages
    ADD CONSTRAINT wiki_pages_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: wiki_pages_wiki_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY wiki_pages
    ADD CONSTRAINT wiki_pages_wiki_id_fk FOREIGN KEY (wiki_id) REFERENCES wikis(id);


--
-- Name: zip_file_imports_attachment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zip_file_imports
    ADD CONSTRAINT zip_file_imports_attachment_id_fk FOREIGN KEY (attachment_id) REFERENCES attachments(id);


--
-- Name: zip_file_imports_folder_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zip_file_imports
    ADD CONSTRAINT zip_file_imports_folder_id_fk FOREIGN KEY (folder_id) REFERENCES folders(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO public;

INSERT INTO schema_migrations (version) VALUES ('20101210192618');

INSERT INTO schema_migrations (version) VALUES ('20101216224513');

INSERT INTO schema_migrations (version) VALUES ('20110102070652');

INSERT INTO schema_migrations (version) VALUES ('20110118001335');

INSERT INTO schema_migrations (version) VALUES ('20110203205300');

INSERT INTO schema_migrations (version) VALUES ('20110208031356');

INSERT INTO schema_migrations (version) VALUES ('20110214180525');

INSERT INTO schema_migrations (version) VALUES ('20110217231741');

INSERT INTO schema_migrations (version) VALUES ('20110220031603');

INSERT INTO schema_migrations (version) VALUES ('20110223175857');

INSERT INTO schema_migrations (version) VALUES ('20110302054028');

INSERT INTO schema_migrations (version) VALUES ('20110303133300');

INSERT INTO schema_migrations (version) VALUES ('20110307163027');

INSERT INTO schema_migrations (version) VALUES ('20110308223938');

INSERT INTO schema_migrations (version) VALUES ('20110311052615');

INSERT INTO schema_migrations (version) VALUES ('20110315144328');

INSERT INTO schema_migrations (version) VALUES ('20110321151227');

INSERT INTO schema_migrations (version) VALUES ('20110321204131');

INSERT INTO schema_migrations (version) VALUES ('20110321234519');

INSERT INTO schema_migrations (version) VALUES ('20110322164900');

INSERT INTO schema_migrations (version) VALUES ('20110325162810');

INSERT INTO schema_migrations (version) VALUES ('20110325200936');

INSERT INTO schema_migrations (version) VALUES ('20110329223720');

INSERT INTO schema_migrations (version) VALUES ('20110330192602');

INSERT INTO schema_migrations (version) VALUES ('20110330204732');

INSERT INTO schema_migrations (version) VALUES ('20110331145021');

INSERT INTO schema_migrations (version) VALUES ('20110401163322');

INSERT INTO schema_migrations (version) VALUES ('20110401214033');

INSERT INTO schema_migrations (version) VALUES ('20110405210006');

INSERT INTO schema_migrations (version) VALUES ('20110409232339');

INSERT INTO schema_migrations (version) VALUES ('20110411214502');

INSERT INTO schema_migrations (version) VALUES ('20110412154600');

INSERT INTO schema_migrations (version) VALUES ('20110414160750');

INSERT INTO schema_migrations (version) VALUES ('20110415103900');

INSERT INTO schema_migrations (version) VALUES ('20110416052050');

INSERT INTO schema_migrations (version) VALUES ('20110420162000');

INSERT INTO schema_migrations (version) VALUES ('20110426161613');

INSERT INTO schema_migrations (version) VALUES ('20110503231936');

INSERT INTO schema_migrations (version) VALUES ('20110505055435');

INSERT INTO schema_migrations (version) VALUES ('20110505141533');

INSERT INTO schema_migrations (version) VALUES ('20110510155237');

INSERT INTO schema_migrations (version) VALUES ('20110510171100');

INSERT INTO schema_migrations (version) VALUES ('20110510180611');

INSERT INTO schema_migrations (version) VALUES ('20110511194408');

INSERT INTO schema_migrations (version) VALUES ('20110513162300');

INSERT INTO schema_migrations (version) VALUES ('20110516222325');

INSERT INTO schema_migrations (version) VALUES ('20110516225834');

INSERT INTO schema_migrations (version) VALUES ('20110516233821');

INSERT INTO schema_migrations (version) VALUES ('20110520164623');

INSERT INTO schema_migrations (version) VALUES ('20110522035309');

INSERT INTO schema_migrations (version) VALUES ('20110525175614');

INSERT INTO schema_migrations (version) VALUES ('20110526154853');

INSERT INTO schema_migrations (version) VALUES ('20110527155754');

INSERT INTO schema_migrations (version) VALUES ('20110531144916');

INSERT INTO schema_migrations (version) VALUES ('20110601222447');

INSERT INTO schema_migrations (version) VALUES ('20110602202130');

INSERT INTO schema_migrations (version) VALUES ('20110602202133');

INSERT INTO schema_migrations (version) VALUES ('20110606160200');

INSERT INTO schema_migrations (version) VALUES ('20110609212540');

INSERT INTO schema_migrations (version) VALUES ('20110610163600');

INSERT INTO schema_migrations (version) VALUES ('20110610213249');

INSERT INTO schema_migrations (version) VALUES ('20110617200149');

INSERT INTO schema_migrations (version) VALUES ('20110706183249');

INSERT INTO schema_migrations (version) VALUES ('20110708151915');

INSERT INTO schema_migrations (version) VALUES ('20110708231141');

INSERT INTO schema_migrations (version) VALUES ('20110720185610');

INSERT INTO schema_migrations (version) VALUES ('20110801034931');

INSERT INTO schema_migrations (version) VALUES ('20110801080015');

INSERT INTO schema_migrations (version) VALUES ('20110803192001');

INSERT INTO schema_migrations (version) VALUES ('20110804195852');

INSERT INTO schema_migrations (version) VALUES ('20110805003024');

INSERT INTO schema_migrations (version) VALUES ('20110809193507');

INSERT INTO schema_migrations (version) VALUES ('20110809221718');

INSERT INTO schema_migrations (version) VALUES ('20110810194057');

INSERT INTO schema_migrations (version) VALUES ('20110816152405');

INSERT INTO schema_migrations (version) VALUES ('20110816203511');

INSERT INTO schema_migrations (version) VALUES ('20110817173455');

INSERT INTO schema_migrations (version) VALUES ('20110817193126');

INSERT INTO schema_migrations (version) VALUES ('20110817210423');

INSERT INTO schema_migrations (version) VALUES ('20110819205044');

INSERT INTO schema_migrations (version) VALUES ('20110820021607');

INSERT INTO schema_migrations (version) VALUES ('20110822151806');

INSERT INTO schema_migrations (version) VALUES ('20110824191941');

INSERT INTO schema_migrations (version) VALUES ('20110825131747');

INSERT INTO schema_migrations (version) VALUES ('20110825214829');

INSERT INTO schema_migrations (version) VALUES ('20110826153155');

INSERT INTO schema_migrations (version) VALUES ('20110830152834');

INSERT INTO schema_migrations (version) VALUES ('20110830154202');

INSERT INTO schema_migrations (version) VALUES ('20110830213208');

INSERT INTO schema_migrations (version) VALUES ('20110831210257');

INSERT INTO schema_migrations (version) VALUES ('20110901153920');

INSERT INTO schema_migrations (version) VALUES ('20110901202140');

INSERT INTO schema_migrations (version) VALUES ('20110902032958');

INSERT INTO schema_migrations (version) VALUES ('20110902033742');

INSERT INTO schema_migrations (version) VALUES ('20110906215826');

INSERT INTO schema_migrations (version) VALUES ('20110908150019');

INSERT INTO schema_migrations (version) VALUES ('20110913171819');

INSERT INTO schema_migrations (version) VALUES ('20110914215543');

INSERT INTO schema_migrations (version) VALUES ('20110920163900');

INSERT INTO schema_migrations (version) VALUES ('20110920163901');

INSERT INTO schema_migrations (version) VALUES ('20110920165939');

INSERT INTO schema_migrations (version) VALUES ('20110925050308');

INSERT INTO schema_migrations (version) VALUES ('20110927163700');

INSERT INTO schema_migrations (version) VALUES ('20110928191843');

INSERT INTO schema_migrations (version) VALUES ('20110930041946');

INSERT INTO schema_migrations (version) VALUES ('20110930122100');

INSERT INTO schema_migrations (version) VALUES ('20110930235857');

INSERT INTO schema_migrations (version) VALUES ('20111005201509');

INSERT INTO schema_migrations (version) VALUES ('20111007115900');

INSERT INTO schema_migrations (version) VALUES ('20111007115901');

INSERT INTO schema_migrations (version) VALUES ('20111007143900');

INSERT INTO schema_migrations (version) VALUES ('20111007172800');

INSERT INTO schema_migrations (version) VALUES ('20111010173231');

INSERT INTO schema_migrations (version) VALUES ('20111010205553');

INSERT INTO schema_migrations (version) VALUES ('20111010214049');

INSERT INTO schema_migrations (version) VALUES ('20111010223224');

INSERT INTO schema_migrations (version) VALUES ('20111017124400');

INSERT INTO schema_migrations (version) VALUES ('20111017165221');

INSERT INTO schema_migrations (version) VALUES ('20111018221343');

INSERT INTO schema_migrations (version) VALUES ('20111019152833');

INSERT INTO schema_migrations (version) VALUES ('20111020191436');

INSERT INTO schema_migrations (version) VALUES ('20111021161157');

INSERT INTO schema_migrations (version) VALUES ('20111021210121');

INSERT INTO schema_migrations (version) VALUES ('20111024163214');

INSERT INTO schema_migrations (version) VALUES ('20111026055002');

INSERT INTO schema_migrations (version) VALUES ('20111026193530');

INSERT INTO schema_migrations (version) VALUES ('20111026193841');

INSERT INTO schema_migrations (version) VALUES ('20111026201231');

INSERT INTO schema_migrations (version) VALUES ('20111031145929');

INSERT INTO schema_migrations (version) VALUES ('20111108150000');

INSERT INTO schema_migrations (version) VALUES ('20111109005013');

INSERT INTO schema_migrations (version) VALUES ('20111111165300');

INSERT INTO schema_migrations (version) VALUES ('20111111225824');

INSERT INTO schema_migrations (version) VALUES ('20111114164345');

INSERT INTO schema_migrations (version) VALUES ('20111117202549');

INSERT INTO schema_migrations (version) VALUES ('20111118221746');

INSERT INTO schema_migrations (version) VALUES ('20111121175219');

INSERT INTO schema_migrations (version) VALUES ('20111122162413');

INSERT INTO schema_migrations (version) VALUES ('20111122162607');

INSERT INTO schema_migrations (version) VALUES ('20111122172335');

INSERT INTO schema_migrations (version) VALUES ('20111123022449');

INSERT INTO schema_migrations (version) VALUES ('20111128172716');

INSERT INTO schema_migrations (version) VALUES ('20111128205419');

INSERT INTO schema_migrations (version) VALUES ('20111128212056');

INSERT INTO schema_migrations (version) VALUES ('20111209000047');

INSERT INTO schema_migrations (version) VALUES ('20111209054726');

INSERT INTO schema_migrations (version) VALUES ('20111209171640');

INSERT INTO schema_migrations (version) VALUES ('20111212152629');

INSERT INTO schema_migrations (version) VALUES ('20111221230443');

INSERT INTO schema_migrations (version) VALUES ('20111223215543');

INSERT INTO schema_migrations (version) VALUES ('20111228210808');

INSERT INTO schema_migrations (version) VALUES ('20111230165936');

INSERT INTO schema_migrations (version) VALUES ('20111230172131');

INSERT INTO schema_migrations (version) VALUES ('20120103235126');

INSERT INTO schema_migrations (version) VALUES ('20120104170646');

INSERT INTO schema_migrations (version) VALUES ('20120104183918');

INSERT INTO schema_migrations (version) VALUES ('20120105201643');

INSERT INTO schema_migrations (version) VALUES ('20120105205517');

INSERT INTO schema_migrations (version) VALUES ('20120105210857');

INSERT INTO schema_migrations (version) VALUES ('20120105221640');

INSERT INTO schema_migrations (version) VALUES ('20120106220543');

INSERT INTO schema_migrations (version) VALUES ('20120111202225');

INSERT INTO schema_migrations (version) VALUES ('20120111205512');

INSERT INTO schema_migrations (version) VALUES ('20120115222635');

INSERT INTO schema_migrations (version) VALUES ('20120116151831');

INSERT INTO schema_migrations (version) VALUES ('20120118163059');

INSERT INTO schema_migrations (version) VALUES ('20120120161346');

INSERT INTO schema_migrations (version) VALUES ('20120120190358');

INSERT INTO schema_migrations (version) VALUES ('20120124171424');

INSERT INTO schema_migrations (version) VALUES ('20120125012723');

INSERT INTO schema_migrations (version) VALUES ('20120125210130');

INSERT INTO schema_migrations (version) VALUES ('20120126200026');

INSERT INTO schema_migrations (version) VALUES ('20120127035651');

INSERT INTO schema_migrations (version) VALUES ('20120131001222');

INSERT INTO schema_migrations (version) VALUES ('20120131001505');

INSERT INTO schema_migrations (version) VALUES ('20120201044246');

INSERT INTO schema_migrations (version) VALUES ('20120206224055');

INSERT INTO schema_migrations (version) VALUES ('20120207210631');

INSERT INTO schema_migrations (version) VALUES ('20120207222938');

INSERT INTO schema_migrations (version) VALUES ('20120208180341');

INSERT INTO schema_migrations (version) VALUES ('20120208213400');

INSERT INTO schema_migrations (version) VALUES ('20120209223909');

INSERT INTO schema_migrations (version) VALUES ('20120210173646');

INSERT INTO schema_migrations (version) VALUES ('20120210200324');

INSERT INTO schema_migrations (version) VALUES ('20120215193327');

INSERT INTO schema_migrations (version) VALUES ('20120216163427');

INSERT INTO schema_migrations (version) VALUES ('20120216214454');

INSERT INTO schema_migrations (version) VALUES ('20120217214153');

INSERT INTO schema_migrations (version) VALUES ('20120220193121');

INSERT INTO schema_migrations (version) VALUES ('20120221204244');

INSERT INTO schema_migrations (version) VALUES ('20120221220828');

INSERT INTO schema_migrations (version) VALUES ('20120224194847');

INSERT INTO schema_migrations (version) VALUES ('20120224194848');

INSERT INTO schema_migrations (version) VALUES ('20120227192729');

INSERT INTO schema_migrations (version) VALUES ('20120227194305');

INSERT INTO schema_migrations (version) VALUES ('20120228203647');

INSERT INTO schema_migrations (version) VALUES ('20120229203255');

INSERT INTO schema_migrations (version) VALUES ('20120301210107');

INSERT INTO schema_migrations (version) VALUES ('20120301231339');

INSERT INTO schema_migrations (version) VALUES ('20120301231546');

INSERT INTO schema_migrations (version) VALUES ('20120302175325');

INSERT INTO schema_migrations (version) VALUES ('20120305234941');

INSERT INTO schema_migrations (version) VALUES ('20120307154947');

INSERT INTO schema_migrations (version) VALUES ('20120307190206');

INSERT INTO schema_migrations (version) VALUES ('20120307222744');

INSERT INTO schema_migrations (version) VALUES ('20120309165333');

INSERT INTO schema_migrations (version) VALUES ('20120316233922');

INSERT INTO schema_migrations (version) VALUES ('20120319184846');

INSERT INTO schema_migrations (version) VALUES ('20120320171426');

INSERT INTO schema_migrations (version) VALUES ('20120322170426');

INSERT INTO schema_migrations (version) VALUES ('20120322184742');

INSERT INTO schema_migrations (version) VALUES ('20120324000220');

INSERT INTO schema_migrations (version) VALUES ('20120326021418');

INSERT INTO schema_migrations (version) VALUES ('20120326023214');

INSERT INTO schema_migrations (version) VALUES ('20120328162105');

INSERT INTO schema_migrations (version) VALUES ('20120330151054');

INSERT INTO schema_migrations (version) VALUES ('20120330163358');

INSERT INTO schema_migrations (version) VALUES ('20120402054554');

INSERT INTO schema_migrations (version) VALUES ('20120402054921');

INSERT INTO schema_migrations (version) VALUES ('20120404151043');

INSERT INTO schema_migrations (version) VALUES ('20120404230916');

INSERT INTO schema_migrations (version) VALUES ('20120417133444');

INSERT INTO schema_migrations (version) VALUES ('20120422213535');

INSERT INTO schema_migrations (version) VALUES ('20120425161928');

INSERT INTO schema_migrations (version) VALUES ('20120425180934');

INSERT INTO schema_migrations (version) VALUES ('20120425201730');

INSERT INTO schema_migrations (version) VALUES ('20120427162634');

INSERT INTO schema_migrations (version) VALUES ('20120430164933');

INSERT INTO schema_migrations (version) VALUES ('20120501160019');

INSERT INTO schema_migrations (version) VALUES ('20120501213908');

INSERT INTO schema_migrations (version) VALUES ('20120502144730');

INSERT INTO schema_migrations (version) VALUES ('20120502190901');

INSERT INTO schema_migrations (version) VALUES ('20120502212620');

INSERT INTO schema_migrations (version) VALUES ('20120505003400');

INSERT INTO schema_migrations (version) VALUES ('20120510004759');

INSERT INTO schema_migrations (version) VALUES ('20120511173314');

INSERT INTO schema_migrations (version) VALUES ('20120514215405');

INSERT INTO schema_migrations (version) VALUES ('20120515055355');

INSERT INTO schema_migrations (version) VALUES ('20120516152445');

INSERT INTO schema_migrations (version) VALUES ('20120516185217');

INSERT INTO schema_migrations (version) VALUES ('20120517150920');

INSERT INTO schema_migrations (version) VALUES ('20120517222224');

INSERT INTO schema_migrations (version) VALUES ('20120518154752');

INSERT INTO schema_migrations (version) VALUES ('20120518160716');

INSERT INTO schema_migrations (version) VALUES ('20120518212446');

INSERT INTO schema_migrations (version) VALUES ('20120522145514');

INSERT INTO schema_migrations (version) VALUES ('20120522163145');

INSERT INTO schema_migrations (version) VALUES ('20120523145010');

INSERT INTO schema_migrations (version) VALUES ('20120523153500');

INSERT INTO schema_migrations (version) VALUES ('20120525174337');

INSERT INTO schema_migrations (version) VALUES ('20120530201701');

INSERT INTO schema_migrations (version) VALUES ('20120530213835');

INSERT INTO schema_migrations (version) VALUES ('20120531150712');

INSERT INTO schema_migrations (version) VALUES ('20120531183543');

INSERT INTO schema_migrations (version) VALUES ('20120531221324');

INSERT INTO schema_migrations (version) VALUES ('20120601195648');

INSERT INTO schema_migrations (version) VALUES ('20120603222842');

INSERT INTO schema_migrations (version) VALUES ('20120604223644');

INSERT INTO schema_migrations (version) VALUES ('20120607164022');

INSERT INTO schema_migrations (version) VALUES ('20120607181141');

INSERT INTO schema_migrations (version) VALUES ('20120607195540');

INSERT INTO schema_migrations (version) VALUES ('20120608165313');

INSERT INTO schema_migrations (version) VALUES ('20120608191051');

INSERT INTO schema_migrations (version) VALUES ('20120613214030');

INSERT INTO schema_migrations (version) VALUES ('20120615012036');

INSERT INTO schema_migrations (version) VALUES ('20120619203203');

INSERT INTO schema_migrations (version) VALUES ('20120619203536');

INSERT INTO schema_migrations (version) VALUES ('20120620171523');

INSERT INTO schema_migrations (version) VALUES ('20120620184804');

INSERT INTO schema_migrations (version) VALUES ('20120620185247');

INSERT INTO schema_migrations (version) VALUES ('20120620190441');

INSERT INTO schema_migrations (version) VALUES ('20120621214317');

INSERT INTO schema_migrations (version) VALUES ('20120626174816');

INSERT INTO schema_migrations (version) VALUES ('20120629215700');

INSERT INTO schema_migrations (version) VALUES ('20120630213457');

INSERT INTO schema_migrations (version) VALUES ('20120702185313');

INSERT INTO schema_migrations (version) VALUES ('20120702212634');

INSERT INTO schema_migrations (version) VALUES ('20120705144244');

INSERT INTO schema_migrations (version) VALUES ('20120709180215');

INSERT INTO schema_migrations (version) VALUES ('20120710190752');

INSERT INTO schema_migrations (version) VALUES ('20120711214917');

INSERT INTO schema_migrations (version) VALUES ('20120711215013');

INSERT INTO schema_migrations (version) VALUES ('20120716204625');

INSERT INTO schema_migrations (version) VALUES ('20120717140514');

INSERT INTO schema_migrations (version) VALUES ('20120717140515');

INSERT INTO schema_migrations (version) VALUES ('20120717202155');

INSERT INTO schema_migrations (version) VALUES ('20120718161934');

INSERT INTO schema_migrations (version) VALUES ('20120723201110');

INSERT INTO schema_migrations (version) VALUES ('20120723201410');

INSERT INTO schema_migrations (version) VALUES ('20120723201957');

INSERT INTO schema_migrations (version) VALUES ('20120724172904');

INSERT INTO schema_migrations (version) VALUES ('20120727145852');

INSERT INTO schema_migrations (version) VALUES ('20120802163230');

INSERT INTO schema_migrations (version) VALUES ('20120802204119');

INSERT INTO schema_migrations (version) VALUES ('20120810212309');

INSERT INTO schema_migrations (version) VALUES ('20120813165554');

INSERT INTO schema_migrations (version) VALUES ('20120814205244');

INSERT INTO schema_migrations (version) VALUES ('20120817191623');

INSERT INTO schema_migrations (version) VALUES ('20120820141609');

INSERT INTO schema_migrations (version) VALUES ('20120820215005');

INSERT INTO schema_migrations (version) VALUES ('20120917230202');

INSERT INTO schema_migrations (version) VALUES ('20120918220940');

INSERT INTO schema_migrations (version) VALUES ('20120920154904');

INSERT INTO schema_migrations (version) VALUES ('20120921155127');

INSERT INTO schema_migrations (version) VALUES ('20120921203351');

INSERT INTO schema_migrations (version) VALUES ('20120924171046');

INSERT INTO schema_migrations (version) VALUES ('20120924181235');

INSERT INTO schema_migrations (version) VALUES ('20120924205209');

INSERT INTO schema_migrations (version) VALUES ('20120927184213');

INSERT INTO schema_migrations (version) VALUES ('20121001190034');

INSERT INTO schema_migrations (version) VALUES ('20121003200645');

INSERT INTO schema_migrations (version) VALUES ('20121016230032');

INSERT INTO schema_migrations (version) VALUES ('20121017124430');

INSERT INTO schema_migrations (version) VALUES ('20121017165813');

INSERT INTO schema_migrations (version) VALUES ('20121017165823');

INSERT INTO schema_migrations (version) VALUES ('20121018205505');

INSERT INTO schema_migrations (version) VALUES ('20121019185800');

INSERT INTO schema_migrations (version) VALUES ('20121029182508');

INSERT INTO schema_migrations (version) VALUES ('20121029214423');

INSERT INTO schema_migrations (version) VALUES ('20121112230145');

INSERT INTO schema_migrations (version) VALUES ('20121113002813');

INSERT INTO schema_migrations (version) VALUES ('20121115205740');

INSERT INTO schema_migrations (version) VALUES ('20121115210333');

INSERT INTO schema_migrations (version) VALUES ('20121115220718');

INSERT INTO schema_migrations (version) VALUES ('20121119201743');

INSERT INTO schema_migrations (version) VALUES ('20121120180117');

INSERT INTO schema_migrations (version) VALUES ('20121126224708');

INSERT INTO schema_migrations (version) VALUES ('20121127174920');

INSERT INTO schema_migrations (version) VALUES ('20121127212421');

INSERT INTO schema_migrations (version) VALUES ('20121129175438');

INSERT INTO schema_migrations (version) VALUES ('20121129230914');

INSERT INTO schema_migrations (version) VALUES ('20121203164800');

INSERT INTO schema_migrations (version) VALUES ('20121206040918');

INSERT INTO schema_migrations (version) VALUES ('20121206201052');

INSERT INTO schema_migrations (version) VALUES ('20121207193355');

INSERT INTO schema_migrations (version) VALUES ('20121210154140');

INSERT INTO schema_migrations (version) VALUES ('20121212050526');

INSERT INTO schema_migrations (version) VALUES ('20121218215625');

INSERT INTO schema_migrations (version) VALUES ('20121228182649');

INSERT INTO schema_migrations (version) VALUES ('20130103191206');

INSERT INTO schema_migrations (version) VALUES ('20130110212740');

INSERT INTO schema_migrations (version) VALUES ('20130114214157');

INSERT INTO schema_migrations (version) VALUES ('20130114214749');

INSERT INTO schema_migrations (version) VALUES ('20130114215024');

INSERT INTO schema_migrations (version) VALUES ('20130115163556');

INSERT INTO schema_migrations (version) VALUES ('20130118000423');

INSERT INTO schema_migrations (version) VALUES ('20130118162201');

INSERT INTO schema_migrations (version) VALUES ('20130121212107');

INSERT INTO schema_migrations (version) VALUES ('20130121212340');

INSERT INTO schema_migrations (version) VALUES ('20130122193536');

INSERT INTO schema_migrations (version) VALUES ('20130123035558');

INSERT INTO schema_migrations (version) VALUES ('20130124203149');

INSERT INTO schema_migrations (version) VALUES ('20130125234216');

INSERT INTO schema_migrations (version) VALUES ('20130128192930');

INSERT INTO schema_migrations (version) VALUES ('20130128220410');

INSERT INTO schema_migrations (version) VALUES ('20130128221236');

INSERT INTO schema_migrations (version) VALUES ('20130128221237');

INSERT INTO schema_migrations (version) VALUES ('20130130195248');

INSERT INTO schema_migrations (version) VALUES ('20130130202130');

INSERT INTO schema_migrations (version) VALUES ('20130130203358');

INSERT INTO schema_migrations (version) VALUES ('20130215164701');

INSERT INTO schema_migrations (version) VALUES ('20130220000433');

INSERT INTO schema_migrations (version) VALUES ('20130221052614');

INSERT INTO schema_migrations (version) VALUES ('20130226233029');

INSERT INTO schema_migrations (version) VALUES ('20130227205659');

INSERT INTO schema_migrations (version) VALUES ('20130307214055');

INSERT INTO schema_migrations (version) VALUES ('20130310212252');

INSERT INTO schema_migrations (version) VALUES ('20130310213118');

INSERT INTO schema_migrations (version) VALUES ('20130312024749');

INSERT INTO schema_migrations (version) VALUES ('20130312231026');

INSERT INTO schema_migrations (version) VALUES ('20130313141722');

INSERT INTO schema_migrations (version) VALUES ('20130313162706');

INSERT INTO schema_migrations (version) VALUES ('20130319120204');

INSERT INTO schema_migrations (version) VALUES ('20130320190243');

INSERT INTO schema_migrations (version) VALUES ('20130325204913');

INSERT INTO schema_migrations (version) VALUES ('20130326210659');

INSERT INTO schema_migrations (version) VALUES ('20130401031740');

INSERT INTO schema_migrations (version) VALUES ('20130401032003');

INSERT INTO schema_migrations (version) VALUES ('20130405213030');

INSERT INTO schema_migrations (version) VALUES ('20130411031858');

INSERT INTO schema_migrations (version) VALUES ('20130416170936');

INSERT INTO schema_migrations (version) VALUES ('20130416190214');

INSERT INTO schema_migrations (version) VALUES ('20130417153307');

INSERT INTO schema_migrations (version) VALUES ('20130419193229');

INSERT INTO schema_migrations (version) VALUES ('20130422191502');

INSERT INTO schema_migrations (version) VALUES ('20130422205650');

INSERT INTO schema_migrations (version) VALUES ('20130423162205');

INSERT INTO schema_migrations (version) VALUES ('20130425230856');

INSERT INTO schema_migrations (version) VALUES ('20130429190927');

INSERT INTO schema_migrations (version) VALUES ('20130429201937');

INSERT INTO schema_migrations (version) VALUES ('20130430215057');

INSERT INTO schema_migrations (version) VALUES ('20130502200753');

INSERT INTO schema_migrations (version) VALUES ('20130506191104');

INSERT INTO schema_migrations (version) VALUES ('20130508214241');

INSERT INTO schema_migrations (version) VALUES ('20130509173346');

INSERT INTO schema_migrations (version) VALUES ('20130511131825');

INSERT INTO schema_migrations (version) VALUES ('20130516174336');

INSERT INTO schema_migrations (version) VALUES ('20130516204101');

INSERT INTO schema_migrations (version) VALUES ('20130516205837');

INSERT INTO schema_migrations (version) VALUES ('20130520205654');

INSERT INTO schema_migrations (version) VALUES ('20130521161315');

INSERT INTO schema_migrations (version) VALUES ('20130521163706');

INSERT INTO schema_migrations (version) VALUES ('20130521181412');

INSERT INTO schema_migrations (version) VALUES ('20130521223335');

INSERT INTO schema_migrations (version) VALUES ('20130523162832');

INSERT INTO schema_migrations (version) VALUES ('20130524164516');

INSERT INTO schema_migrations (version) VALUES ('20130528204902');

INSERT INTO schema_migrations (version) VALUES ('20130531135600');

INSERT INTO schema_migrations (version) VALUES ('20130531140200');

INSERT INTO schema_migrations (version) VALUES ('20130603181545');

INSERT INTO schema_migrations (version) VALUES ('20130603211207');

INSERT INTO schema_migrations (version) VALUES ('20130603213307');

INSERT INTO schema_migrations (version) VALUES ('20130604174602');

INSERT INTO schema_migrations (version) VALUES ('20130605211012');

INSERT INTO schema_migrations (version) VALUES ('20130606170923');

INSERT INTO schema_migrations (version) VALUES ('20130606170924');

INSERT INTO schema_migrations (version) VALUES ('20130610174505');

INSERT INTO schema_migrations (version) VALUES ('20130610204053');

INSERT INTO schema_migrations (version) VALUES ('20130611194212');

INSERT INTO schema_migrations (version) VALUES ('20130612201431');

INSERT INTO schema_migrations (version) VALUES ('20130613174529');

INSERT INTO schema_migrations (version) VALUES ('20130617152008');

INSERT INTO schema_migrations (version) VALUES ('20130624174549');

INSERT INTO schema_migrations (version) VALUES ('20130624174615');

INSERT INTO schema_migrations (version) VALUES ('20130626220656');

INSERT INTO schema_migrations (version) VALUES ('20130628215434');

INSERT INTO schema_migrations (version) VALUES ('20130701160407');

INSERT INTO schema_migrations (version) VALUES ('20130701160408');

INSERT INTO schema_migrations (version) VALUES ('20130701193624');

INSERT INTO schema_migrations (version) VALUES ('20130701210202');

INSERT INTO schema_migrations (version) VALUES ('20130702104734');

INSERT INTO schema_migrations (version) VALUES ('20130703165456');

INSERT INTO schema_migrations (version) VALUES ('20130708201319');

INSERT INTO schema_migrations (version) VALUES ('20130712230314');

INSERT INTO schema_migrations (version) VALUES ('20130719192808');

INSERT INTO schema_migrations (version) VALUES ('20130724222101');

INSERT INTO schema_migrations (version) VALUES ('20130726205640');

INSERT INTO schema_migrations (version) VALUES ('20130726230550');

INSERT INTO schema_migrations (version) VALUES ('20130729210315');

INSERT INTO schema_migrations (version) VALUES ('20130730162545');

INSERT INTO schema_migrations (version) VALUES ('20130730163939');

INSERT INTO schema_migrations (version) VALUES ('20130730164252');

INSERT INTO schema_migrations (version) VALUES ('20130802164854');

INSERT INTO schema_migrations (version) VALUES ('20130807165221');

INSERT INTO schema_migrations (version) VALUES ('20130807194322');

INSERT INTO schema_migrations (version) VALUES ('20130813195331');

INSERT INTO schema_migrations (version) VALUES ('20130813195454');

INSERT INTO schema_migrations (version) VALUES ('20130816182601');

INSERT INTO schema_migrations (version) VALUES ('20130820202205');

INSERT INTO schema_migrations (version) VALUES ('20130820210303');

INSERT INTO schema_migrations (version) VALUES ('20130820210746');

INSERT INTO schema_migrations (version) VALUES ('20130822214514');

INSERT INTO schema_migrations (version) VALUES ('20130823204503');

INSERT INTO schema_migrations (version) VALUES ('20130826215926');

INSERT INTO schema_migrations (version) VALUES ('20130828191910');

INSERT INTO schema_migrations (version) VALUES ('20130905190311');

INSERT INTO schema_migrations (version) VALUES ('20130911191937');

INSERT INTO schema_migrations (version) VALUES ('20130911200910');

INSERT INTO schema_migrations (version) VALUES ('20130916174630');

INSERT INTO schema_migrations (version) VALUES ('20130916192409');

INSERT INTO schema_migrations (version) VALUES ('20130917194106');

INSERT INTO schema_migrations (version) VALUES ('20130917194107');

INSERT INTO schema_migrations (version) VALUES ('20130918193333');

INSERT INTO schema_migrations (version) VALUES ('20130924153118');

INSERT INTO schema_migrations (version) VALUES ('20130924163929');

INSERT INTO schema_migrations (version) VALUES ('20131001193112');

INSERT INTO schema_migrations (version) VALUES ('20131003195758');

INSERT INTO schema_migrations (version) VALUES ('20131003202023');

INSERT INTO schema_migrations (version) VALUES ('20131003221953');

INSERT INTO schema_migrations (version) VALUES ('20131003222037');

INSERT INTO schema_migrations (version) VALUES ('20131014185902');

INSERT INTO schema_migrations (version) VALUES ('20131022192816');

INSERT INTO schema_migrations (version) VALUES ('20131023154151');

INSERT INTO schema_migrations (version) VALUES ('20131023205614');

INSERT INTO schema_migrations (version) VALUES ('20131023221034');

INSERT INTO schema_migrations (version) VALUES ('20131025153323');

INSERT INTO schema_migrations (version) VALUES ('20131105175802');

INSERT INTO schema_migrations (version) VALUES ('20131105230615');

INSERT INTO schema_migrations (version) VALUES ('20131105232029');

INSERT INTO schema_migrations (version) VALUES ('20131105234428');

INSERT INTO schema_migrations (version) VALUES ('20131106161158');

INSERT INTO schema_migrations (version) VALUES ('20131106171153');

INSERT INTO schema_migrations (version) VALUES ('20131111221538');

INSERT INTO schema_migrations (version) VALUES ('20131111224434');

INSERT INTO schema_migrations (version) VALUES ('20131112184904');

INSERT INTO schema_migrations (version) VALUES ('20131115165908');

INSERT INTO schema_migrations (version) VALUES ('20131115221720');

INSERT INTO schema_migrations (version) VALUES ('20131120173358');

INSERT INTO schema_migrations (version) VALUES ('20131202173569');

INSERT INTO schema_migrations (version) VALUES ('20131205162354');

INSERT INTO schema_migrations (version) VALUES ('20131206221858');

INSERT INTO schema_migrations (version) VALUES ('20131216190859');

INSERT INTO schema_migrations (version) VALUES ('20131224010801');

INSERT INTO schema_migrations (version) VALUES ('20131230182437');

INSERT INTO schema_migrations (version) VALUES ('20131230213011');

INSERT INTO schema_migrations (version) VALUES ('20131231182558');

INSERT INTO schema_migrations (version) VALUES ('20131231182559');

INSERT INTO schema_migrations (version) VALUES ('20131231194442');

INSERT INTO schema_migrations (version) VALUES ('20140110201409');

INSERT INTO schema_migrations (version) VALUES ('20140115230951');

INSERT INTO schema_migrations (version) VALUES ('20140116220413');

INSERT INTO schema_migrations (version) VALUES ('20140117195133');

INSERT INTO schema_migrations (version) VALUES ('20140120201847');

INSERT INTO schema_migrations (version) VALUES ('20140124163739');

INSERT INTO schema_migrations (version) VALUES ('20140124173117');

INSERT INTO schema_migrations (version) VALUES ('20140127203558');

INSERT INTO schema_migrations (version) VALUES ('20140127204017');

INSERT INTO schema_migrations (version) VALUES ('20140128205246');

INSERT INTO schema_migrations (version) VALUES ('20140131163737');

INSERT INTO schema_migrations (version) VALUES ('20140131164925');

INSERT INTO schema_migrations (version) VALUES ('20140131231659');

INSERT INTO schema_migrations (version) VALUES ('20140204180348');

INSERT INTO schema_migrations (version) VALUES ('20140204235601');

INSERT INTO schema_migrations (version) VALUES ('20140205171002');

INSERT INTO schema_migrations (version) VALUES ('20140206203334');

INSERT INTO schema_migrations (version) VALUES ('20140224212704');

INSERT INTO schema_migrations (version) VALUES ('20140227171812');

INSERT INTO schema_migrations (version) VALUES ('20140228201739');

INSERT INTO schema_migrations (version) VALUES ('20140303160957');

INSERT INTO schema_migrations (version) VALUES ('20140311223045');

INSERT INTO schema_migrations (version) VALUES ('20140312232054');

INSERT INTO schema_migrations (version) VALUES ('20140314220629');

INSERT INTO schema_migrations (version) VALUES ('20140318150809');

INSERT INTO schema_migrations (version) VALUES ('20140319223606');

INSERT INTO schema_migrations (version) VALUES ('20140322132112');

INSERT INTO schema_migrations (version) VALUES ('20140401224701');

INSERT INTO schema_migrations (version) VALUES ('20140402204820');

INSERT INTO schema_migrations (version) VALUES ('20140403213959');

INSERT INTO schema_migrations (version) VALUES ('20140404162351');

INSERT INTO schema_migrations (version) VALUES ('20140410164417');

INSERT INTO schema_migrations (version) VALUES ('20140414230423');

INSERT INTO schema_migrations (version) VALUES ('20140417143325');

INSERT INTO schema_migrations (version) VALUES ('20140417220141');

INSERT INTO schema_migrations (version) VALUES ('20140418210000');

INSERT INTO schema_migrations (version) VALUES ('20140418211204');

INSERT INTO schema_migrations (version) VALUES ('20140423003242');

INSERT INTO schema_migrations (version) VALUES ('20140423034044');

INSERT INTO schema_migrations (version) VALUES ('20140428182624');

INSERT INTO schema_migrations (version) VALUES ('20140505211339');

INSERT INTO schema_migrations (version) VALUES ('20140505215131');

INSERT INTO schema_migrations (version) VALUES ('20140505215510');

INSERT INTO schema_migrations (version) VALUES ('20140505223637');

INSERT INTO schema_migrations (version) VALUES ('20140506200812');

INSERT INTO schema_migrations (version) VALUES ('20140507204231');

INSERT INTO schema_migrations (version) VALUES ('20140509161648');

INSERT INTO schema_migrations (version) VALUES ('20140512180015');

INSERT INTO schema_migrations (version) VALUES ('20140512213941');

INSERT INTO schema_migrations (version) VALUES ('20140515163333');

INSERT INTO schema_migrations (version) VALUES ('20140516160845');

INSERT INTO schema_migrations (version) VALUES ('20140516215613');

INSERT INTO schema_migrations (version) VALUES ('20140519163623');

INSERT INTO schema_migrations (version) VALUES ('20140519221522');

INSERT INTO schema_migrations (version) VALUES ('20140519221523');

INSERT INTO schema_migrations (version) VALUES ('20140520152745');

INSERT INTO schema_migrations (version) VALUES ('20140521183128');

INSERT INTO schema_migrations (version) VALUES ('20140522190519');

INSERT INTO schema_migrations (version) VALUES ('20140522231727');

INSERT INTO schema_migrations (version) VALUES ('20140523142858');

INSERT INTO schema_migrations (version) VALUES ('20140523164418');

INSERT INTO schema_migrations (version) VALUES ('20140523175853');

INSERT INTO schema_migrations (version) VALUES ('20140527170951');

INSERT INTO schema_migrations (version) VALUES ('20140529220933');

INSERT INTO schema_migrations (version) VALUES ('20140530195058');

INSERT INTO schema_migrations (version) VALUES ('20140530195059');

INSERT INTO schema_migrations (version) VALUES ('20140603193939');

INSERT INTO schema_migrations (version) VALUES ('20140604180158');

INSERT INTO schema_migrations (version) VALUES ('20140606184901');

INSERT INTO schema_migrations (version) VALUES ('20140606220920');

INSERT INTO schema_migrations (version) VALUES ('20140609195358');

INSERT INTO schema_migrations (version) VALUES ('20140613194434');

INSERT INTO schema_migrations (version) VALUES ('20140616202420');

INSERT INTO schema_migrations (version) VALUES ('20140617211933');

INSERT INTO schema_migrations (version) VALUES ('20140628015850');

INSERT INTO schema_migrations (version) VALUES ('20140707221306');

INSERT INTO schema_migrations (version) VALUES ('20140710153035');

INSERT INTO schema_migrations (version) VALUES ('20140710211240');

INSERT INTO schema_migrations (version) VALUES ('20140717183855');

INSERT INTO schema_migrations (version) VALUES ('20140722150150');

INSERT INTO schema_migrations (version) VALUES ('20140722151057');

INSERT INTO schema_migrations (version) VALUES ('20140723220226');

INSERT INTO schema_migrations (version) VALUES ('20140728202458');

INSERT INTO schema_migrations (version) VALUES ('20140805174406');

INSERT INTO schema_migrations (version) VALUES ('20140805194100');

INSERT INTO schema_migrations (version) VALUES ('20140806161233');

INSERT INTO schema_migrations (version) VALUES ('20140806162559');

INSERT INTO schema_migrations (version) VALUES ('20140809142615');

INSERT INTO schema_migrations (version) VALUES ('20140815192313');

INSERT INTO schema_migrations (version) VALUES ('20140818134232');

INSERT INTO schema_migrations (version) VALUES ('20140818144041');

INSERT INTO schema_migrations (version) VALUES ('20140819210933');

INSERT INTO schema_migrations (version) VALUES ('20140821130508');

INSERT INTO schema_migrations (version) VALUES ('20140821171612');

INSERT INTO schema_migrations (version) VALUES ('20140822192941');

INSERT INTO schema_migrations (version) VALUES ('20140825163916');

INSERT INTO schema_migrations (version) VALUES ('20140825200057');

INSERT INTO schema_migrations (version) VALUES ('20140903152155');

INSERT INTO schema_migrations (version) VALUES ('20140903164913');

INSERT INTO schema_migrations (version) VALUES ('20140903191721');

INSERT INTO schema_migrations (version) VALUES ('20140904193057');

INSERT INTO schema_migrations (version) VALUES ('20140904214619');

INSERT INTO schema_migrations (version) VALUES ('20140905171322');

INSERT INTO schema_migrations (version) VALUES ('20140915174918');

INSERT INTO schema_migrations (version) VALUES ('20140916195352');

INSERT INTO schema_migrations (version) VALUES ('20140917205347');

INSERT INTO schema_migrations (version) VALUES ('20140919170019');

INSERT INTO schema_migrations (version) VALUES ('20140925153437');

INSERT INTO schema_migrations (version) VALUES ('20140930123844');

INSERT INTO schema_migrations (version) VALUES ('20141001211428');

INSERT INTO schema_migrations (version) VALUES ('20141008142620');

INSERT INTO schema_migrations (version) VALUES ('20141008201112');

INSERT INTO schema_migrations (version) VALUES ('20141010172524');

INSERT INTO schema_migrations (version) VALUES ('20141015132218');

INSERT INTO schema_migrations (version) VALUES ('20141022192431');

INSERT INTO schema_migrations (version) VALUES ('20141023050715');

INSERT INTO schema_migrations (version) VALUES ('20141023120911');

INSERT INTO schema_migrations (version) VALUES ('20141023164759');

INSERT INTO schema_migrations (version) VALUES ('20141023171507');

INSERT INTO schema_migrations (version) VALUES ('20141024045542');

INSERT INTO schema_migrations (version) VALUES ('20141024155909');

INSERT INTO schema_migrations (version) VALUES ('20141029163245');

INSERT INTO schema_migrations (version) VALUES ('20141104213722');

INSERT INTO schema_migrations (version) VALUES ('20141106211024');

INSERT INTO schema_migrations (version) VALUES ('20141106213431');

INSERT INTO schema_migrations (version) VALUES ('20141109202906');

INSERT INTO schema_migrations (version) VALUES ('20141110133207');

INSERT INTO schema_migrations (version) VALUES ('20141112204534');

INSERT INTO schema_migrations (version) VALUES ('20141113211810');

INSERT INTO schema_migrations (version) VALUES ('20141115100802');

INSERT INTO schema_migrations (version) VALUES ('20141115282315');

INSERT INTO schema_migrations (version) VALUES ('20141115282316');

INSERT INTO schema_migrations (version) VALUES ('20141119233751');

INSERT INTO schema_migrations (version) VALUES ('20141125133305');

INSERT INTO schema_migrations (version) VALUES ('20141125212000');

INSERT INTO schema_migrations (version) VALUES ('20141202202750');

INSERT INTO schema_migrations (version) VALUES ('20141204222243');

INSERT INTO schema_migrations (version) VALUES ('20141205172247');

INSERT INTO schema_migrations (version) VALUES ('20141209081016');

INSERT INTO schema_migrations (version) VALUES ('20141210062449');

INSERT INTO schema_migrations (version) VALUES ('20141210112542');

INSERT INTO schema_migrations (version) VALUES ('20141212134557');

INSERT INTO schema_migrations (version) VALUES ('20141226194222');

INSERT INTO schema_migrations (version) VALUES ('20150105210803');

INSERT INTO schema_migrations (version) VALUES ('20150214141428');

INSERT INTO schema_migrations (version) VALUES ('20150223181357');

INSERT INTO schema_migrations (version) VALUES ('20150225214754');

INSERT INTO schema_migrations (version) VALUES ('20150225215853');

INSERT INTO schema_migrations (version) VALUES ('20150227011742');

INSERT INTO schema_migrations (version) VALUES ('20150227013111');

INSERT INTO schema_migrations (version) VALUES ('20150228203409');