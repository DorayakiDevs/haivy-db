Create or replace function forward_ticket(ticket_id uuid, from_staff uuid, to_staff uuid)
returns void as $$
begin
insert into public.ticket_interaction_history (ticket_id, action, note, by) VALUES (ticket_id, 'forward', 'Forwarded from ' || from_staff || ' to ' || to_staff, auth.uid());

UPDATE public.ticket
SET assigned_to = to_staff
WHERE ticket.ticket_id = forward_ticket.ticket_id
AND assigned_to = from_staff;

end;
$$ language plpgsql;