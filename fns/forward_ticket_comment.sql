CREATE OR REPLACE FUNCTION forward_ticket_comment(ticket_id uuid, from_staff UUID, to_staff UUID, note TEXT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.ticket_interaction_history (ticket_id, action, note, by)
    VALUES (ticket_id, 'forward', 'Forwarded from ' || from_staff || ' to ' || to_staff || '.\nComment: ' || note, auth.uid());
    
    UPDATE public.ticket
    SET assigned_to = to_staff
    WHERE ticket.ticket_id = forward_ticket.ticket_id
    AND assigned_to = from_staff;
END;
$$ LANGUAGE plpgsql;