export type Folder={id:string;name:string;position:number};
export type Board={id:string;name:string;folder_id:string|null;position:number;archived_at:string|null;trashed_at:string|null};
export type Epic={id:string;board_id:string;title:string;notes:string;target_date:string|null;completed_at:string|null;archived_at:string|null;trashed_at:string|null};
export type Task={id:string;board_id:string;epic_id:string|null;parent_id:string|null;title:string;notes:string;status:"todo"|"in_progress"|"done";effort:"small"|"medium"|"large"|null;priority:"low"|"normal"|"high";due_date:string|null;position:number;archived_at:string|null;trashed_at:string|null;version:number};
export type Goal={id:string;title:string;description:string;period:"week"|"month"|"three_months"|"six_months"|"year"|"custom";start_date:string;end_date:string;status:"active"|"achieved"|"archived";achieved_at:string|null};
export type Plan={id:string;plan_date:string;focus:string;version:number;daily_plan_items:{id:string;task_id:string|null;position:number;title_snapshot:string;completion_snapshot:boolean|null}[]};
export type Activity={task_id:string;event:string;occurred_at:string};
