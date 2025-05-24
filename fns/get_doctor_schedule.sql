create or  replace function get_doctor_schedule_with_date(date_required date)
returns json as
$$
declare json_result json;
begin
-- start return the json
select jsonb_agg(   
    /*
    Note: about the store type of jsonb_agg()* and  json_agg()**
    (*) store type is binary and it's arrange the field alphabetically, remove whitespaces and normalize number (eg: select '{"count": 01.00}'::json the result will be {"count":1.0})
    (**) store type is text, it's preserve any format and does not remove whitespaces, number will not be normalize (eg: select '{"count": 01.00}'::json the result will be {"count":01.00})
    These differences only affect back-end's queries.
    */
    jsonb_build_object(
    'meeting_date', apt.meeting_date,
    'duration', apt.duration,
    'status', apt.status,
    'content', apt.content,
    'patient_information', jsonb_build_object(
        'uuid', pt.patient_uid,
        'account_uid', ad.account_uid,
        'full_name', concat(ad.first_name,' ', ad.last_name),--this will return null if either first or last name is null
        'dob', ad.dob,
        'profile_picrure', ad.profile_picture,
        'account_type', ad.account_type
    ),
    'ticket_id', ti.ticket_id

)
) into json_result

    from appointment apt
    join ticket ti on ti.assigned_to = apt.staff_id
    join patient pt on pt.patient_uid = apt.patient_uid
    join accountdetails ad on ad.account_uid = apt.staff_id
    where apt.meeting_date = date_required;

    return json_result;
end;
$$ language plpgsql;
