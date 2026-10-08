"use client";
import {useCallback,useEffect,useState} from "react";
import {createClient} from "@/lib/supabase/client";
import type{Activity,Board,Epic,Folder,Goal,Plan,Task}from "@/lib/types";

export function usePlanar(ownerId:string){
 const db=createClient(); const [folders,setFolders]=useState<Folder[]>([]),[boards,setBoards]=useState<Board[]>([]),[epics,setEpics]=useState<Epic[]>([]),[tasks,setTasks]=useState<Task[]>([]),[goals,setGoals]=useState<Goal[]>([]),[plans,setPlans]=useState<Plan[]>([]),[activity,setActivity]=useState<Activity[]>([]),[loading,setLoading]=useState(true),[error,setError]=useState("");
 const load=useCallback(async()=>{setLoading(true);setError("");const [f,b,e,t,g,p,a]=await Promise.all([
  db.from("folders").select("*").order("position"),db.from("boards").select("*").order("position"),db.from("epics").select("*").order("position"),
  db.from("tasks").select("*").order("position"),db.from("goals").select("*").order("start_date",{ascending:false}),
  db.from("daily_plans").select("*,daily_plan_items(*)").order("plan_date",{ascending:false}),db.from("task_activity").select("task_id,event,occurred_at").order("occurred_at",{ascending:false})
 ]);const first=[f,b,e,t,g,p,a].find(x=>x.error);if(first?.error)setError(first.error.message);else{setFolders((f.data??[])as Folder[]);setBoards((b.data??[])as Board[]);setEpics((e.data??[])as Epic[]);setTasks((t.data??[])as Task[]);setGoals((g.data??[])as Goal[]);setPlans(((p.data??[])as Plan[]).map(x=>({...x,daily_plan_items:[...x.daily_plan_items].sort((a,b)=>a.position-b.position)})));setActivity((a.data??[])as Activity[])}setLoading(false)},[]);
 useEffect(()=>{void load()},[load]);
 async function insert<T>(table:string,row:Record<string,unknown>){const {data,error}=await db.from(table).insert({...row,owner_id:ownerId}).select().single();if(error)throw error;await load();return data as T}
 async function update(table:string,id:string,row:Record<string,unknown>){const {error}=await db.from(table).update(row).eq("id",id);if(error)throw error;await load()}
 async function remove(table:string,id:string){const {error}=await db.from(table).delete().eq("id",id);if(error)throw error;await load()}
 async function savePlan(date:string,focus:string,ids:string[],version?:number){const {error}=await db.rpc("save_daily_plan",{p_date:date,p_focus:focus,p_task_ids:ids,p_expected_version:version??null});if(error)throw error;await load()}
 return{folders,boards,epics,tasks,goals,plans,activity,loading,error,setError,load,insert,update,remove,savePlan};
}
