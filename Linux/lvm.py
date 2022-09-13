#!/usr/bin/python
import sys
import os

class lvm:
    def __init__(self):
        self.lvs = os.popen("lvs | grep -v LV | awk '{print $1}'").read().split()
        self.vgs = os.popen("vgs | grep -v VG | awk '{print $1}'").read().split()
        self.pvs = os.popen("ls /dev/ | grep 'sd\|vd' | grep -v dvd").read().split()
        self.action = ""
    def todo(self):
        print """==========================================================================
1. List all Physical Volumes(PV)
2. List all Volume Groups(VG)
3. List all Logical Volumes(LV)
4. Extend a VG
5. Extend a LV (100% FREE)
6. Exit
        """
        opt={ 1: "pvs_listing", 2: "vgs_listing", 3: "lvs_listing", 4: "vg_extend", 5: "lv_extend", 6: "exit" }
        choice=raw_input("Your choise: ")
        try:
            choice=int(choice)
        except ValueError:
            print "Oops, please enter a valid option."
            self.todo()
        if choice >= 1 and choice <= len(opt):
            self.action=opt[choice]
        else:
            print "Oops, please enter a valid option."
            self.todo()
    def Action(self):
        if self.action == "pvs_listing":
            self.pvs_listing()
        elif self.action == "vgs_listing":
            self.vgs_listing()
        elif self.action == "lvs_listing":
            self.lvs_listing()
        elif self.action == "vg_extend":
            self.vg_extend()
        elif self.action == "lv_extend":
            self.lv_extend()
        elif self.action == "exit":
            self.exit()
        else:
            print "Unkown action, please try again"
            main()
    def pvs_listing(self):
        print "Your current PVs: "
        j = 1
        for i in self.pvs:
            print "%s - %s" % (j,i)
            j += 1
    def lvs_listing(self):
        j = 1
        print "Your current LVs: "
        for i in self.lvs:
            print "%s - %s" % (j,i)
            j += 1
    def vgs_listing(self):
        j = 1
        print "Your current VGs: "
        for i in self.vgs:
            print "%s - %s" % (j,i)
            j += 1
    def choose_vg(self):
        i = 1
        self.vgs_listing()
        opttable = dict()
        for j in self.vgs:
            opttable[i] = j
            i += 1
        vg_choose = raw_input("Choose a VG to extend: ")
        try:
            vg_choose = int(vg_choose)
        except:
            print "Wrong option, return to the top menu."
            vg_choose = 10
            self.choose_vg()
        if vg_choose >= 1 and vg_choose <= len(opttable):
            vg_choosed = opttable[vg_choose]
            return vg_choosed
        else:
            print "VG not found. "
            self.choose_vg()
    def vg_extend(self):
        vg_name = self.choose_vg()
        pv_name = self.choose_pv()
        confirm = raw_input("Your choice: - VG: %s, PV: %s. Are you sure? [y/n] " % (vg_name,pv_name))
        if confirm == "y" or confirm == "Y":
            print "Executing..."
            os.system("vgextend -v %s /dev/%s" % (vg_name,pv_name))
        elif confirm == "n" or confirm == "N":
            print "Return to VG-extend menu."
            self.vg_extend()
        else:
            print "Oops, invalid option, return to the top menu."
            main()

    def choose_pv(self):
        i = 1
        self.pvs_listing()
        opttable = dict ()
        for j in self.pvs:
            opttable[i] = j
            i += 1
        pv_choose = raw_input("Choose a PV to extend: ")
        try:
            pv_choose = int(pv_choose)
        except:
            print "Oops, please enter a valid option."
            pv_choose = 10
            self.choose_pv()
        if pv_choose >=1 and pv_choose <= len(opttable):
            pv_choosed = opttable[pv_choose]
            return pv_choosed
        else:
            print "PV not found."
            self.choose_pv()
    def choose_lv(self):
        i = 1
        self.lvs_listing()
        opttable = dict()
        for j in self.lvs:
            opttable[i] = j
            i += 1
        lv_choose = raw_input("Choose a LV to extend: ")
        try:
            lv_choose = int(lv_choose)
        except:
            print "Oops, please enter a valid option."
            lv_choose = 10
            self.choose_lv()
        if lv_choose >=1 and lv_choose <= len(opttable):
            lv_choosed = opttable[lv_choose]
            return lv_choosed
        else:
            print "LV not found."
            self.choose_lv()
    def lv_extend(self):
        lv_name = self.choose_lv()
        vg_name = str(os.popen("lvs | grep %s | awk '{print $2}'" % (lv_name)).read()).split()
        print "Your choice: - LV: %s, VG: %s" %(lv_name, vg_name[0])
        confirm = raw_input("This LV will be extend from 100% FREE USAGE. Are you sure? [y/n] ")
        if confirm == "y" or confirm == "Y":
            print "Executing..."
            os.system(str("lvextend -v -l +100\%FREE -r /dev/") + vg_name[0] + '\/' + lv_name)
        elif confirm == "n" or confirm == "N":
            print "Return to LV-extend menu."
            self.lv_extend()
        else:
            print "Oops, invalid option, return to the top menu."
            main()

    def exit(self):
        sys.exit()

def main():
    while True:
        new_lvm = lvm()
        new_lvm.todo()
        new_lvm.Action()
main()
