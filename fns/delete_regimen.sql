create or replace function dev.delete_regimen(p_regimen_id uuid)
returns void as
$$
begin
    if not(check_roles(array['administrator', 'manager'])::role[]) then
    then
    raise exception 'You do not have permission to perform this action';
    end if;
    begin
    update on regimens
    set is_available = false
    where regimen_id = p_regimen_id;
    exception
    when others then
    raise exception 'Something went wrong while trying to delete regimen: %', SQLERRM;
    end;
end;
$$
language plpgsql;