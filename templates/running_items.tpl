<ul>
    % for job in jobs:
    <li>{{job.id}} - {{job._status}}<br />
        last heartbeat: {{job.last_heartbeat}}</li>
    % end
</ul>