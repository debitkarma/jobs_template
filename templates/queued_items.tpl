<ul>
    % for job in jobs:
    <li>{{job.id}} - {{job._status}}</li>
    % end
</ul>