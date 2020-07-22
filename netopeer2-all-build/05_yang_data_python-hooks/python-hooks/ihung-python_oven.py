#!/usr/bin/env python3
from __future__ import print_function
import sysrepo as sr
import sys

#oven state value determining whether the food is inside the oven or not 
food_inside=0
#oven state value determining whether the food is waiting for the oven to be ready 
insert_food_on_ready=0
#oven state value determining the current temperature of the oven 
oven_temperature=250
#oven config value stored locally just so that it is not needed to ask sysrepo for it all the time
config_temperature=0


# Helper function for printing changes given operation, old and new value.
def print_change(op, old_val, new_val):
    if (op == sr.SR_OP_CREATED):
           print("CREATED: ",end='')
           print(new_val.to_string(),end='')
    elif (op == sr.SR_OP_DELETED):
           print("DELETED: ",end='')
           print(old_val.to_string(),end='')
    elif (op == sr.SR_OP_MODIFIED):
           print("MODIFIED: ",end='')
           print("old value",end='')
           print(old_val.to_string(),end='')
           print("new value",end='')
           print(new_val.to_string(),end='')
    elif (op == sr.SR_OP_MOVED):
        print("MOVED: " + new_val.xpath() + " after " + old_val.xpath())


# Helper function for printing events.
def ev_to_str(ev):
    if (ev == sr.SR_EV_CHANGE):
        return "change"
    elif (ev == sr.SR_EV_DONE):
        return "done"
    elif (ev == sr.SR_EV_VERIFY):
        return "verify"
    elif (ev == sr.SR_EV_APPLY):
        return "apply"
    elif (ev == sr.SR_EV_ABORT):
        return "abort"
    else:
        return "abort"

# Function to print current configuration state.
# It does so by loading all the items of a session and printing them out.
def print_current_config(session, module_name):
    select_xpath = "/" + module_name + ":*//*"

    values = session.get_items(select_xpath)

    for i in range(values.val_cnt()):
        print(values.val(i).to_string(),end='')

def oven_insert_food_cb(session, op_path, input, input_cnt, event, request_id, output, output_cnt, private_data):

    try:
        print("\n\n ========== RPC CALLED for insert food START ==========\n")

        global insert_food_on_ready
        global food_inside

        insert_food_on_ready = 0
        food_inside = 1

        print("\n   OVEN: Food put into the oven.\n");
        print("\n\n ========== RPC CALLED for insert food END==========\n")
    
    except Exception as e:
        print(e)

    return sr.SR_ERR_OK
    

def oven_remove_food_cb(session, op_path, input, input_cnt, event, request_id, output, output_cnt, private_data):

    try:
        print("\n\n ========== RPC CALLED for remove food START ==========\n")

        global insert_food_on_ready
        global food_inside
        
        if food_inside == "0":
            print("\n   OVEN: Food not in the oven.\n")
            return sr.SR_ERR_OPERATION_FAILED

        food_inside = 0

        print("\n   OVEN: Food taken out of the oven.\n");
        print("\n\n ========== RPC CALLED for remove food END==========\n")
    
    except Exception as e:
        print(e)

    return sr.SR_ERR_OK

# Function to be called for subscribed client of given session whenever configuration changes.
def module_change_cb(sess, module_name, xpath, event, request_id, private_data):

    try:
        print ("\n\n ========== Notification " + ev_to_str(event) + " =============================================\n")
        if (sr.SR_EV_CHANGE == event):
            print("\n ========== CONFIG HAS CHANGED, CURRENT RUNNING CONFIG: ==========\n")
            print_current_config(sess, module_name);

        print("\n ========== CHANGES: =============================================\n")

        change_path = "/" + module_name + ":*//."

        it = sess.get_changes_iter(change_path);

        while True:
            change = sess.get_change_next(it)
            if change == None:
                break
            print_change(change.oper(), change.old_val(), change.new_val())

        print("\n\n ========== END OF CHANGES =======================================\n")

    except Exception as e:
        print(e)

    return sr.SR_ERR_OK

def oven_state_cb(session, module_name, path, request_xpath, request_id, parent, private_data):
    print("\n\n oven_state_cb in \n")
    print("\n\n ========== CALLBACK CALLED TO PROVIDE \"" + path + "\" DATA ==========\n")
    try:
        ctx = session.get_context()
        mod = ctx.get_module(module_name)

        parent.reset(sr.Data_Node(ctx, "/oven:oven-state", None, sr.LYD_ANYDATA_CONSTSTRING, 0))
        tmpr = sr.Data_Node(parent, mod, "temperature", "3")
        foodIn = sr.Data_Node(parent, mod, "food-inside", "true")

    except Exception as e:
        print(e)
        return sr.SR_ERR_OK
    sys.stdout.flush()
    return sr.SR_ERR_OK


try:
    module_name = "oven"
    if len(sys.argv) > 1:
        module_name = sys.argv[1]
    else:
        print("\nYou can pass the module name to be subscribed as the first argument")

    print("Application will watch for changes in " +  module_name + "\n")

    # connect to sysrepo
    conn = sr.Connection(sr.SR_CONN_DEFAULT)

    # start session
    sess = sr.Session(conn)

    # subscribe for changes in running config */
    subscribe = sr.Subscribe(sess)

    #subscribe.module_change_subscribe(module_name, module_change_cb, None, None, 0, sr.SR_SUBSCR_DONE_ONLY)
    subscribe.module_change_subscribe(module_name, module_change_cb, None, None, 0, sr.SR_SUBSCR_DONE_ONLY|sr.SR_SUBSCR_ENABLED)

    #subscribe.rpc_subscribe("/oven:insert-food", oven_insert_food_cb, sr.SR_SUBSCR_CTX_REUSE)
    #subscribe.rpc_subscribe("/oven:remove-food", oven_remove_food_cb, sr.SR_SUBSCR_CTX_REUSE)
    subscribe.rpc_subscribe("/oven:insert-food", oven_insert_food_cb, None, 0, sr.SR_SUBSCR_CTX_REUSE)
    subscribe.rpc_subscribe("/oven:remove-food", oven_remove_food_cb, None, 0, sr.SR_SUBSCR_CTX_REUSE)

    subscribe.oper_get_items_subscribe(module_name, "/oven:oven-state", oven_state_cb, None, sr.SR_SUBSCR_CTX_REUSE)

    print("\n\n ========== READING RUNNING CONFIG: ==========\n")
    try:
        print_current_config(sess, module_name);
    except Exception as e:
        print(e)

    sr.global_loop()
    
    subscribe.unsubscribe()

    sess.session_stop()

    conn=None

    print("Application exit requested, exiting.\n")

except Exception as e:
    print(e)

