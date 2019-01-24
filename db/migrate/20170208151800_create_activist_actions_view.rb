class CreateActivistActionsView < ActiveRecord::Migration
  def up
    execute %Q{
create or replace view activist_actions as
select t.action,
        t.widget_id,
        t.mobilization_id,
        t.community_id,
        t.activist_id,
        t.action_created_date,
        t.activist_created_at,
        t.activist_email,
        t.first_action
from
    (select 'form_entries'::text as action,
            w.id as widget_id,
            m.id as mobilization_id,
            m.community_id,
            fe.activist_id,
            fe.created_at as action_created_date,
            a.created_at as activist_created_at,
            a.email as activist_email,
            case
                when a.created_at::date = fe.created_at::date then 'sim'::text
                else 'não'::text
            end as first_action
    from form_entries fe
    join activists a on a.id = fe.activist_id
    join widgets w on w.id = fe.widget_id
    join blocks b on b.id = w.block_id
    join mobilizations m on m.id = b.mobilization_id
    union all select 'activist_pressures'::text as action,
                    w.id as widget_id,
                    m.id as mobilization_id,
                    m.community_id,
                    ap.activist_id,
                    ap.created_at as action_created_date,
                    a.created_at as activist_created_at,
                    a.email as activist_email,
                    case
                        when a.created_at = ap.created_at then 'sim'::text
                        else 'não'::text
                    end as first_action
    from activist_pressures ap
    join activists a on a.id = ap.activist_id
    join widgets w on w.id = ap.widget_id
    join blocks b on b.id = w.block_id
    join mobilizations m on m.id = b.mobilization_id
    union all select 'donation'::text as action,
                    w.id as widget_id,
                    m.id as mobilization_id,
                    m.community_id,
                    d.activist_id,
                    d.created_at as action_created_date,
                    a.created_at as activist_created_at,
                    a.email as activist_email,
                    case
                        when a.created_at = d.created_at then 'sim'::text
                        else 'não'::text
                    end as first_action
    from donations d
    join activists a on a.id = d.activist_id
    join widgets w on w.id = d.widget_id
    join blocks b on b.id = w.block_id
    join mobilizations m on m.id = b.mobilization_id) t;
}
  end

  def down
    execute %Q{drop view activist_actions;}
  end
end
