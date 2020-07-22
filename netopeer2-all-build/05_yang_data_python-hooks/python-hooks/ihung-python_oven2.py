#!/usr/bin/env python3
from __future__ import print_function
import sysrepo as sr
import sys
#import yang as ly

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
           print("\t CREATED: ",end='')
           print(new_val.to_string(),end='')
    elif (op == sr.SR_OP_DELETED):
           print("\t DELETED: ",end='')
           print(old_val.to_string(),end='')
    elif (op == sr.SR_OP_MODIFIED):
           print("\t MODIFIED: ",end='')
           print("old value",end='')
           print(old_val.to_string(),end='')
           print("new value",end='')
           print(new_val.to_string(),end='')
    elif (op == sr.SR_OP_MOVED):
        print("\t MOVED: " + new_val.xpath() + " after " + old_val.xpath())


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
def print_current_config(session, select_xpath):
#    select_xpath = "/" + module_name + ":*//*"

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

def process_lan_ip(it, change, old_val, new_val):
    lan_ip_created=[]
    lan_ip_created_dict={"XPATH_INST":None}
    lan_ip_deleted=[]
    lan_ip_deleted_dict={}
    lan_ip_modified=[]
    lan_ip_modified_dict={}
    lan_ip_moved=[]
    lan_ip_moved_dict={}

    if (change.oper() == sr.SR_OP_CREATED):
        op_string="CREATED"
        print("\t {}: ".format(op_string))

        # while loop run at least one time.
        while change !=  None and change.oper() == sr.SR_OP_CREATED:
            if lan_ip_created_dict["XPATH_INST"] == None:
                c_xpath = change.new_val().xpath() 
                c_node_name = sr.Xpath_Ctx().node_name(c_xpath)
                c_val_to_string = change.new_val().val_to_string()
                #print( "\t c_xpath: {}".format(c_xpath) )
                #print( "\t c_node_name: {}".format(c_node_name) )
                #print( "\t c_val_to_string: {}".format(c_val_to_string) )
                lan_ip_created_dict["XPATH_INST"]=c_xpath.replace("/{}".format(c_node_name), "")
                lan_ip_created_dict[c_node_name]=c_val_to_string
                #print("\t lan_ip_created_dict= {}\n\n".format(lan_ip_created_dict))
            else:
                c_xpath = change.new_val().xpath() 
                c_node_name = sr.Xpath_Ctx().node_name(c_xpath)
                c_val_to_string = change.new_val().val_to_string()
                #print( "\t c_xpath: {}".format(c_xpath) )
                #print( "\t c_node_name: {}".format(c_node_name) )
                #print( "\t c_val_to_string: {}".format(c_val_to_string) )
                if lan_ip_created_dict["XPATH_INST"] == c_xpath.replace("/{}".format(c_node_name), ""):
                    lan_ip_created_dict[c_node_name]=c_val_to_string
                    #print("\t lan_ip_created_dict= {}\n\n".format(lan_ip_created_dict))
                else:
                    # We need to append lan_ip_created_dict{} intto lan_ip_created[], and then use a new lan_ip_created_dict{} next time
                    lan_ip_created.append(lan_ip_created_dict)
                    #print("\t lan_ip_created= {}\n\n".format(lan_ip_created))
                    lan_ip_created_dict=dict()
                    lan_ip_created_dict["XPATH_INST"]=c_xpath.replace("/{}".format(c_node_name), "")
                    lan_ip_created_dict[c_node_name]=c_val_to_string
                    #print("\t lan_ip_created_dict= {}\n\n".format(lan_ip_created_dict))

            change = sess.get_change_next(it)
        else:
            if change == None:
                print("\t No more LAN change iterator found... End the process_lan_ip() call. (mesg from {})\n".format(op_string))
                lan_ip_created.append(lan_ip_created_dict)
                lan_ip_created_dict=dict()
                print("\t lan_ip_created= {}".format(lan_ip_created))
            elif change.oper() != sr.SR_OP_CREATED:
                print("\t Not a LAN IP {} operator. Call process_lan_ip() again to prcocess next operator: {}.\n".format(op_string, change.oper()))
                lan_ip_created.append(lan_ip_created_dict)
                lan_ip_created_dict=dict()
                print("\t lan_ip_created= {}".format(lan_ip_created))
                process_lan_ip(it, change, change.old_val(), change.new_val())

    elif (change.oper() == sr.SR_OP_DELETED):
        op_string="DELETED"
        print("\t {}: ".format(op_string))

        # while loop run at least one time.
        while change !=  None and change.oper() == sr.SR_OP_DELETED:
            c_xpath = change.old_val().xpath() 
            c_node_name = sr.Xpath_Ctx().node_name(c_xpath)
            c_val_to_string = change.old_val().val_to_string()
            print( "\t c_xpath: {}".format(c_xpath) )
            print( "\t c_node_name: {}".format(c_node_name) )
            print( "\t c_val_to_string: {}\n\n".format(c_val_to_string) )
            lan_ip_deleted.append(c_val_to_string)

            change = sess.get_change_next(it)
        else:
            if change == None:
                print("\t No more LAN change iterator found... End the process_lan_ip() call. (mesg from {})\n".format(op_string))
                print("\t lan_ip_deleted= {}".format(lan_ip_deleted))
            elif change.oper() != sr.SR_OP_DELETED:
                print("\t Not a LAN IP {} operator. Call process_lan_ip() again to prcocess next operator: {}.\n".format(op_string, change.oper()))
                process_lan_ip(it, change, change.old_val(), change.new_val())

    elif (change.oper() == sr.SR_OP_MODIFIED):
        op_string="MODIFIED"
        print("\t {}: ".format(op_string))

        # while loop run at least one time.
        while change !=  None and change.oper() == sr.SR_OP_MODIFIED:
                c_xpath = change.old_val().xpath() 
                c_node_name = sr.Xpath_Ctx().node_name(c_xpath)
                c_val_to_string = change.old_val().val_to_string()
                print( "\t c_xpath: {}".format(c_xpath) )
                print( "\t c_node_name: {}".format(c_node_name) )
                print( "\t c_val_to_string: {}\n\n".format(c_val_to_string) )
                lan_ip_modified.append(c_val_to_string)

                c_xpath = change.new_val().xpath() 
                c_node_name = sr.Xpath_Ctx().node_name(c_xpath)
                c_val_to_string = change.new_val().val_to_string()
                print( "\t c_xpath: {}".format(c_xpath) )
                print( "\t c_node_name: {}".format(c_node_name) )
                print( "\t c_val_to_string: {}\n\n".format(c_val_to_string) )
                lan_ip_modified.append(c_val_to_string)

                change = sess.get_change_next(it)
        else:
            if change == None:
                print("\t No more LAN change iterator found... End the process_lan_ip() call. (mesg from {})\n".format(op_string))
                print("\t lan_ip_modified= {}".format(lan_ip_modified))
            elif change.oper() != sr.SR_OP_MODIFIED:
                print("\t Not a LAN IP {} operator. Call process_lan_ip() again to prcocess next operator: {}.\n".format(op_string, change.oper()))
                process_lan_ip(it, change, change.old_val(), change.new_val())

    elif (change.oper() == sr.SR_OP_MOVED):
        op_string="MODIFIED"
        print("\t {}: ".format(op_string))

        # while loop run at least one time.
        while change !=  None and change.oper() == sr.SR_OP_MOVED:
            c_xpath = change.old_val().xpath() 
            print( "\t c_xpath_old: {}".format(c_xpath) )
            lan_ip_moved.append(c_xpath)

            c_xpath = change.new_val().xpath() 
            print( "\t c_xpath_new: {}\n\n".format(c_xpath) )
            lan_ip_moved.append(c_xpath)

            change = sess.get_change_next(it)
        else:
            if change == None:
                print("\t No more LAN change iterator found... End the process_lan_ip() call. (mesg from {})\n".format(op_string))
                print("\t lan_ip_moved= {}".format(lan_ip_moved))
            elif change.oper() != sr.SR_OP_MOVED:
                print("\t Not a LAN IP {} operator. Call process_lan_ip() again to prcocess next operator: {}.\n".format(op_string, change.oper()))
                process_lan_ip(it, change, change.old_val(), change.new_val())

def process_change(sess, module_name, change_path):
    """ graber all change nodes and save it for later used inf process_done() """
    it = sess.get_changes_iter(change_path)
    if it is None:
        print("\t Get iterator failed.")
        return sr.SR_ERR_NOT_FOUND

    change = sess.get_change_next(it)
    if change == None:
        print("\t This change_path is not what we want.")
    else:
        process_lan_ip(it, change, change.old_val(), change.new_val())

    print("\n\n")

    return sr.SR_ERR_OK

def process_done(sess, module_name, change_path):
    return sr.SR_ERR_OK

# Function to be called for subscribed client of given session whenever configuration changes.
def module_change_cb(sess, module_name, xpath, event, request_id, private_data):

    try:
        change_path = "/" + module_name + ":oven/Static-IP-Address-List/*//."
        #change_path = "/" + module_name + ":*//."

        '''
        if (sr.SR_EV_CHANGE == event):
            print("\n ========== CONFIG HAS CHANGED, CURRENT RUNNING CONFIG: ==========\n")
            print_current_config(sess, change_path);
        '''


        if (event == sr.SR_EV_CHANGE):
            print ("\n\n ========== IN module_change_cb() - Notification " + ev_to_str(event) + "\n")
            print("\n\t CHANGES: =============================================\n")
            #print("xpath: {}".format(xpath))
            process_change(sess, module_name, change_path)

        elif (event == sr.SR_EV_DONE):
            print ("\n\n ========== IN module_change_cb() - Notification " + ev_to_str(event) + "\n")
            print("\n\t CHANGES: =============================================\n")
            #print("xpath: {}".format(xpath))
            #process_done(sess, module_name, change_path)

        else:
            print ("\n\n ========== IN module_change_cb() - Notification " + ev_to_str(event) + "\n")
        
    
        '''
        it = sess.get_changes_iter(change_path);

        while True:
            change = sess.get_change_next(it)
            if change == None:
                break
            print_change(change.oper(), change.old_val(), change.new_val())

        '''

        print("\n\n\t END OF CHANGES =======================================\n")
        print ("\n\n ========== OUT module_change_cb() - Notification " + ev_to_str(event) + "\n")

    except Exception as e:
        print(e)

    return sr.SR_ERR_OK
def module_change_cb2(sess, module_name, xpath, event, request_id, private_data):

    try:
        print ("\n\n ========== Notification " + ev_to_str(event) + " =============================================\n")

        #change_path = "/" + module_name + ":*//."
        change_path = "/" + module_name + ":oven/ihung-test-node/*//."

        it = sess.get_changes_iter(change_path);
        if it is None:
            print("\t Get iterator failed.")
            return sr.SR_ERR_NOT_FOUND

        '''
        while True:
            change = sess.get_change_next(it)
            if change == None:
                break
            print_change(change.oper(), change.old_val(), change.new_val())
        '''
        change_tree = sess.get_change_tree_next(it)
        new_change_tree=sr.Tree_Change()
        if change_tree == None:
            print("\t change_tree is None")
        else:
            print("repr(change_tree): {}".format(repr(change_tree))) 
            print("repr(new_change_tree): {}".format(repr(new_change_tree))) 
           # print("change_tree.oper(): {}".format(change_tree.oper()))
            print("new_change_tree.oper(): {}".format(new_change_tree.oper()))
            print("new_change_tree.node(): {}".format(new_change_tree.node()))
            print("new_change_tree.node().list_pos(): {}".format(new_change_tree.node().list_pos()))
            print("new_change_tree.prev_value(): {}".format(new_change_tree.prev_value()))
            print("new_change_tree.prev_list(): {}".format(new_change_tree.prev_list()))
            print("new_change_tree.prev_dflt(): {}".format(new_change_tree.prev_dflt()))
          #  print("change_tree.prev_value(): {}".format(new_change_tree.prev_value()))
          #  print(change_tree)

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
    #subscribe.module_change_subscribe(module_name, module_change_cb2, None, None, 0, sr.SR_SUBSCR_DONE_ONLY|sr.SR_SUBSCR_ENABLED)
    subscribe.module_change_subscribe(module_name, module_change_cb, None, None, 0, 0)

    #subscribe.rpc_subscribe("/oven:insert-food", oven_insert_food_cb, sr.SR_SUBSCR_CTX_REUSE)
    #subscribe.rpc_subscribe("/oven:remove-food", oven_remove_food_cb, sr.SR_SUBSCR_CTX_REUSE)
    #subscribe.rpc_subscribe("/oven:insert-food", oven_insert_food_cb, None, 0, sr.SR_SUBSCR_CTX_REUSE)
    #subscribe.rpc_subscribe("/oven:remove-food", oven_remove_food_cb, None, 0, sr.SR_SUBSCR_CTX_REUSE)

    #subscribe.oper_get_items_subscribe(module_name, "/oven:oven-state", oven_state_cb, None, sr.SR_SUBSCR_CTX_REUSE)

    print("\n\n ========== READING RUNNING CONFIG: ==========\n")
    try:
        select_xpath = "/" + module_name + ":*//*"
        print_current_config(sess, select_xpath);
    except Exception as e:
        print(e)

    sr.global_loop()
    
    subscribe.unsubscribe()

    sess.session_stop()

    conn=None

    print("Application exit requested, exiting.\n")

except Exception as e:
    print(e)

