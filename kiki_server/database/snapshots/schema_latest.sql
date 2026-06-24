--
-- PostgreSQL database dump
--

\restrict QjwzzqsJ5WlJzF2HRFD1dpipXNeK2yrZxjUHsqgIER94Q0vAANG04Gtes87cI2c

-- Dumped from database version 15.14 (Debian 15.14-1.pgdg13+1)
-- Dumped by pg_dump version 15.14 (Debian 15.14-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: learning_detail_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.learning_detail_logs (
    id bigint NOT NULL,
    user_id character varying(64) NOT NULL,
    scene_id character varying(128) NOT NULL,
    region_id character varying(128) NOT NULL,
    region_text character varying(128),
    region_text_english character varying(128),
    learned_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.learning_detail_logs OWNER TO postgres;

--
-- Name: learning_detail_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.learning_detail_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.learning_detail_logs_id_seq OWNER TO postgres;

--
-- Name: learning_detail_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.learning_detail_logs_id_seq OWNED BY public.learning_detail_logs.id;


--
-- Name: scene_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scene_categories (
    id character varying(32) NOT NULL,
    name character varying(50) NOT NULL,
    icon character varying(20),
    cover_image character varying(500),
    description character varying(200),
    display_order integer DEFAULT 0,
    is_new boolean DEFAULT false,
    is_visible boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.scene_categories OWNER TO postgres;

--
-- Name: scene_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scene_items (
    id character varying(32) NOT NULL,
    scene_id character varying(32) NOT NULL,
    item_type character varying(20) DEFAULT 'chinese'::character varying,
    item_index integer,
    text character varying(50),
    text_pinyin character varying(100),
    text_english character varying(100),
    coordinates jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.scene_items OWNER TO postgres;

--
-- Name: scenes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scenes (
    id character varying(32) NOT NULL,
    category_id character varying(32) NOT NULL,
    name character varying(50) NOT NULL,
    cover_image character varying(500),
    interactive_image character varying(500),
    description character varying(200),
    item_count integer DEFAULT 0,
    display_order integer DEFAULT 0,
    is_new boolean DEFAULT false,
    is_visible boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    items_data jsonb DEFAULT '[]'::jsonb,
    name_en character varying(100),
    context text
);


ALTER TABLE public.scenes OWNER TO postgres;

--
-- Name: COLUMN scenes.items_data; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.scenes.items_data IS '场景物品数据（JSON 数组），包含 type, id, index, text, text_pinyin, text_english, coordinate';


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version character varying(32) NOT NULL,
    applied_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: user_learning_records; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_learning_records (
    id character varying(32) NOT NULL,
    user_id character varying(32) NOT NULL,
    scene_id character varying(32) NOT NULL,
    learned_items jsonb DEFAULT '[]'::jsonb,
    learned_item_count integer DEFAULT 0,
    total_study_time integer DEFAULT 0,
    last_study_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_learning_records OWNER TO postgres;

--
-- Name: user_daily_study_stats; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.user_daily_study_stats AS
 SELECT user_learning_records.user_id,
    date(user_learning_records.last_study_at) AS study_date,
    count(DISTINCT user_learning_records.scene_id) AS scenes_count,
    sum(user_learning_records.total_study_time) AS total_time
   FROM public.user_learning_records
  WHERE (user_learning_records.last_study_at IS NOT NULL)
  GROUP BY user_learning_records.user_id, (date(user_learning_records.last_study_at));


ALTER TABLE public.user_daily_study_stats OWNER TO postgres;

--
-- Name: user_favorites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_favorites (
    id character varying(32) NOT NULL,
    user_id character varying(32) NOT NULL,
    scene_id character varying(32) NOT NULL,
    favorited_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.user_favorites OWNER TO postgres;

--
-- Name: user_feedback; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_feedback (
    id bigint NOT NULL,
    user_id character varying(64) NOT NULL,
    feedback_type character varying(32) DEFAULT 'general'::character varying NOT NULL,
    content text NOT NULL,
    contact character varying(128),
    page character varying(128),
    status character varying(16) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.user_feedback OWNER TO postgres;

--
-- Name: user_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_feedback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_feedback_id_seq OWNER TO postgres;

--
-- Name: user_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_feedback_id_seq OWNED BY public.user_feedback.id;


--
-- Name: user_scene_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_scene_progress (
    id bigint NOT NULL,
    user_id character varying(64) NOT NULL,
    scene_id character varying(128) NOT NULL,
    total_regions integer NOT NULL,
    learned_regions jsonb,
    learned_count integer DEFAULT 0,
    stars_earned integer DEFAULT 0,
    total_score integer DEFAULT 0,
    is_completed boolean DEFAULT false,
    first_learned_at timestamp with time zone,
    last_learned_at timestamp with time zone,
    total_study_time integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_scene_progress OWNER TO postgres;

--
-- Name: user_scene_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_scene_progress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_scene_progress_id_seq OWNER TO postgres;

--
-- Name: user_scene_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_scene_progress_id_seq OWNED BY public.user_scene_progress.id;


--
-- Name: user_score_summary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_score_summary (
    user_id character varying(64) NOT NULL,
    total_stars integer DEFAULT 0,
    total_score integer DEFAULT 0,
    completed_scenes integer DEFAULT 0,
    total_study_time integer DEFAULT 0,
    last_active_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_score_summary OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id character varying(255) NOT NULL,
    phone character varying(20) NOT NULL,
    password_hash character varying(255) NOT NULL,
    nickname character varying(50) NOT NULL,
    avatar character varying(500),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_login_at timestamp without time zone,
    login_fail_count integer DEFAULT 0,
    locked_until timestamp without time zone,
    is_deleted boolean DEFAULT false,
    role_type integer,
    is_vip boolean DEFAULT false,
    vip_expire_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: learning_detail_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.learning_detail_logs ALTER COLUMN id SET DEFAULT nextval('public.learning_detail_logs_id_seq'::regclass);


--
-- Name: user_feedback id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_feedback ALTER COLUMN id SET DEFAULT nextval('public.user_feedback_id_seq'::regclass);


--
-- Name: user_scene_progress id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_scene_progress ALTER COLUMN id SET DEFAULT nextval('public.user_scene_progress_id_seq'::regclass);


--
-- Name: learning_detail_logs learning_detail_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.learning_detail_logs
    ADD CONSTRAINT learning_detail_logs_pkey PRIMARY KEY (id);


--
-- Name: scene_categories scene_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scene_categories
    ADD CONSTRAINT scene_categories_pkey PRIMARY KEY (id);


--
-- Name: scene_items scene_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scene_items
    ADD CONSTRAINT scene_items_pkey PRIMARY KEY (id);


--
-- Name: scenes scenes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenes
    ADD CONSTRAINT scenes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: user_scene_progress uk_user_scene; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_scene_progress
    ADD CONSTRAINT uk_user_scene UNIQUE (user_id, scene_id);


--
-- Name: user_favorites user_favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_favorites
    ADD CONSTRAINT user_favorites_pkey PRIMARY KEY (id);


--
-- Name: user_favorites user_favorites_user_id_scene_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_favorites
    ADD CONSTRAINT user_favorites_user_id_scene_id_key UNIQUE (user_id, scene_id);


--
-- Name: user_feedback user_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_feedback
    ADD CONSTRAINT user_feedback_pkey PRIMARY KEY (id);


--
-- Name: user_learning_records user_learning_records_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_learning_records
    ADD CONSTRAINT user_learning_records_pkey PRIMARY KEY (id);


--
-- Name: user_learning_records user_learning_records_user_id_scene_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_learning_records
    ADD CONSTRAINT user_learning_records_user_id_scene_id_key UNIQUE (user_id, scene_id);


--
-- Name: user_scene_progress user_scene_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_scene_progress
    ADD CONSTRAINT user_scene_progress_pkey PRIMARY KEY (id);


--
-- Name: user_score_summary user_score_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_score_summary
    ADD CONSTRAINT user_score_summary_pkey PRIMARY KEY (user_id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_categories_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_display_order ON public.scene_categories USING btree (display_order);


--
-- Name: idx_categories_visible; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_visible ON public.scene_categories USING btree (is_visible);


--
-- Name: idx_favorites_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_favorites_created ON public.user_favorites USING btree (favorited_at);


--
-- Name: idx_favorites_scene_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_favorites_scene_id ON public.user_favorites USING btree (scene_id);


--
-- Name: idx_favorites_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_favorites_user_id ON public.user_favorites USING btree (user_id);


--
-- Name: idx_items_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_items_index ON public.scene_items USING btree (item_index);


--
-- Name: idx_items_scene_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_items_scene_id ON public.scene_items USING btree (scene_id);


--
-- Name: idx_learning_detail_logs_learned_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_learning_detail_logs_learned_at ON public.learning_detail_logs USING btree (learned_at);


--
-- Name: idx_learning_detail_logs_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_learning_detail_logs_user_id ON public.learning_detail_logs USING btree (user_id);


--
-- Name: idx_learning_detail_logs_user_scene; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_learning_detail_logs_user_scene ON public.learning_detail_logs USING btree (user_id, scene_id);


--
-- Name: idx_learning_last_study; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_learning_last_study ON public.user_learning_records USING btree (last_study_at);


--
-- Name: idx_learning_scene_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_learning_scene_id ON public.user_learning_records USING btree (scene_id);


--
-- Name: idx_learning_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_learning_user_id ON public.user_learning_records USING btree (user_id);


--
-- Name: idx_scenes_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scenes_category_id ON public.scenes USING btree (category_id);


--
-- Name: idx_scenes_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scenes_created_at ON public.scenes USING btree (created_at);


--
-- Name: idx_scenes_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scenes_display_order ON public.scenes USING btree (display_order);


--
-- Name: idx_scenes_visible; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_scenes_visible ON public.scenes USING btree (is_visible);


--
-- Name: idx_user_feedback_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_feedback_created_at ON public.user_feedback USING btree (created_at DESC);


--
-- Name: idx_user_feedback_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_feedback_status ON public.user_feedback USING btree (status);


--
-- Name: idx_user_feedback_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_feedback_user_id ON public.user_feedback USING btree (user_id);


--
-- Name: idx_user_scene_progress_completed; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_scene_progress_completed ON public.user_scene_progress USING btree (is_completed);


--
-- Name: idx_user_scene_progress_last_learned; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_scene_progress_last_learned ON public.user_scene_progress USING btree (last_learned_at);


--
-- Name: idx_user_scene_progress_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_scene_progress_user_id ON public.user_scene_progress USING btree (user_id);


--
-- Name: idx_user_score_summary_completed_scenes; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_score_summary_completed_scenes ON public.user_score_summary USING btree (completed_scenes DESC);


--
-- Name: idx_user_score_summary_last_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_score_summary_last_active ON public.user_score_summary USING btree (last_active_at DESC);


--
-- Name: idx_user_score_summary_total_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_score_summary_total_score ON public.user_score_summary USING btree (total_score DESC);


--
-- Name: idx_users_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_created_at ON public.users USING btree (created_at);


--
-- Name: idx_users_phone; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_phone ON public.users USING btree (phone);


--
-- Name: scene_items scene_items_scene_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scene_items
    ADD CONSTRAINT scene_items_scene_id_fkey FOREIGN KEY (scene_id) REFERENCES public.scenes(id) ON DELETE CASCADE;


--
-- Name: scenes scenes_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenes
    ADD CONSTRAINT scenes_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.scene_categories(id) ON DELETE CASCADE;


--
-- Name: user_favorites user_favorites_scene_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_favorites
    ADD CONSTRAINT user_favorites_scene_id_fkey FOREIGN KEY (scene_id) REFERENCES public.scenes(id) ON DELETE CASCADE;


--
-- Name: user_favorites user_favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_favorites
    ADD CONSTRAINT user_favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_learning_records user_learning_records_scene_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_learning_records
    ADD CONSTRAINT user_learning_records_scene_id_fkey FOREIGN KEY (scene_id) REFERENCES public.scenes(id) ON DELETE CASCADE;


--
-- Name: user_learning_records user_learning_records_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_learning_records
    ADD CONSTRAINT user_learning_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict QjwzzqsJ5WlJzF2HRFD1dpipXNeK2yrZxjUHsqgIER94Q0vAANG04Gtes87cI2c

