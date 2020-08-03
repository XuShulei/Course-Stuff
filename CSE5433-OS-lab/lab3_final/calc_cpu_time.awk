BEGIN{
    startFS = 0;
    endFS = 0;
    detectIncompLine = 0;
}
{
    if ($7 == "[START]") {
        #printf("Catch a start: %s\n", $0);
        #startFS = 1;
        delete user_rt;
        delete proc_rt;
        delete user_last_IN;
        delete user_last_OUT;
        delete proc_last_IN;
        delete proc_last_OUT;
    }
        
    if ($6 == "[FS]" && $7 == "[schedule" && $24 == "jiffies") {
        #cpu_time[uid] = $28 / 1e6 
        uid = $13
        pid = $15
        timeslice =  $20
        #time = $25
        time = $11 / 1e6
        if (!(uid in user_rt) || !(pid in proc_rt)) {
            for (x in user_rt) 
                user_rt[x] = proc_last_IN[x] = user_last_OUT[x] = 0;
            for (x in proc_rt)
                proc_rt[x] = proc_last_IN[x] = proc_last_OUT[x] = 0;
            startFS = time;
            pid_to_user[pid] = uid;
            printf("New user %d or process %d is detected (last IN? %d)\n", uid, pid, user_last_IN[x]);
            print $0
        }
        #if (startFS == 1)
        #    startFS = time;
        endFS = time;
        if ($23 == "IN") {
            user_last_IN[uid] = proc_last_IN[pid] =time;
        } else if ( $23 == "OUT" && user_last_OUT[uid] < time && user_last_IN[uid] !=0) {
            user_last_OUT[uid] = proc_last_OUT[pid] = time;
            if (user_last_OUT[uid] >= user_last_IN[uid])
                user_rt[uid] += (user_last_OUT[uid] - user_last_IN[uid]);
            if (proc_last_OUT[pid] >= proc_last_IN[pid])
                proc_rt[pid] += (proc_last_OUT[pid] - proc_last_IN[pid]);
        }
    }
}
END {
    duration = (endFS-startFS);
    print "\n\n============================================================"
    printf("Last Profiling start at %d, end at %d; %d ms\n", startFS, endFS, duration);
    print "============================================================\n"
        print "------------------------------------------------------------"
    for (x in user_rt) {
        printf ("User %d took %d ms\n", x, user_rt[x]);
        print "------------------------------------------------------------"
    }
        print "\n============================================================\n"
        print "------------------------------------------------------------"

    for (x in proc_rt) {
        printf ("Process %d (belong to User %d) took %d ms\n", x, pid_to_user[x], proc_rt[x]);
        print "------------------------------------------------------------"
    }
        print "\n============================================================"
}
