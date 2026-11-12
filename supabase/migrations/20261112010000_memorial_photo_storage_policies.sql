drop policy if exists "Users can view photos for their deceased profiles"
on storage.objects;

drop policy if exists "Users can upload photos for their deceased profiles"
on storage.objects;

drop policy if exists "Users can delete photos for their deceased profiles"
on storage.objects;

create policy "Users can view photos for their deceased profiles"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'memorial-photos'
  and (
    (storage.foldername(storage.objects.name))[1] = auth.uid()::text
    or exists (
      select 1
      from public.deceased_profiles as profile
      where profile.id::text =
        (storage.foldername(storage.objects.name))[1]
        and profile.user_id = auth.uid()
    )
  )
);

create policy "Users can upload photos for their deceased profiles"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'memorial-photos'
  and (storage.foldername(storage.objects.name))[1] = auth.uid()::text
);

create policy "Users can delete photos for their deceased profiles"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'memorial-photos'
  and (
    (storage.foldername(storage.objects.name))[1] = auth.uid()::text
    or exists (
      select 1
      from public.deceased_profiles as profile
      where profile.id::text =
        (storage.foldername(storage.objects.name))[1]
        and profile.user_id = auth.uid()
    )
  )
);
