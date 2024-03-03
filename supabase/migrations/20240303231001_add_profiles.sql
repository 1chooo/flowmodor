drop policy "Enable update for authenticated users based on user_id" on "public"."settings";

create table "public"."profiles" (
    "id" bigint generated by default as identity not null,
    "user_id" uuid not null,
    "is_new" boolean not null
);


alter table "public"."profiles" enable row level security;

CREATE UNIQUE INDEX profile_pkey ON public.profiles USING btree (id);

CREATE UNIQUE INDEX profile_user_id_key ON public.profiles USING btree (user_id);

alter table "public"."profiles" add constraint "profile_pkey" PRIMARY KEY using index "profile_pkey";

alter table "public"."profiles" add constraint "profile_user_id_key" UNIQUE using index "profile_user_id_key";

alter table "public"."profiles" add constraint "profiles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."profiles" validate constraint "profiles_user_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into public.settings (user_id, break_ratio)
  values (new.id, 5);

  insert into public.plans (user_id, subscription_id)
  values (new.id, NULL);

  insert into public.integrations (user_id, provider, access_token)
  values (new.id, NULL, NULL);

  insert into public.profiles (user_id, is_new)
  values (new.id, true);

  return new;
end;
$function$
;

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

create policy "Enable select for authenticated based on user_id"
on "public"."profiles"
as permissive
for select
to authenticated
using ((auth.uid() = user_id));


create policy "Enable update for authenticated based on user_id"
on "public"."profiles"
as permissive
for update
to authenticated
using ((auth.uid() = user_id));


create policy "Enable update for authenticated users based on user_id"
on "public"."settings"
as permissive
for update
to authenticated
using ((auth.uid() = user_id))
with check (true);






INSERT INTO public.profiles (user_id, is_new)
SELECT
    u.id,
    CASE
        WHEN COUNT(qualifying_logs.user_id) > 0 THEN FALSE
        ELSE TRUE
    END
FROM
    auth.users u
LEFT JOIN
    (SELECT user_id
     FROM logs
     WHERE mode = 'focus'
     AND EXTRACT(EPOCH FROM (end_time - start_time)) >= 10) AS qualifying_logs
ON u.id = qualifying_logs.user_id
GROUP BY u.id
ON CONFLICT (user_id) DO UPDATE SET
    is_new = EXCLUDED.is_new;