package org.vijaytech.oilshop;

public class Organization {
    private int AD_Org_ID;
    private String name;

    public Organization(int AD_Org_ID, String name) {
        this.AD_Org_ID = AD_Org_ID;
        this.name = name;
    }

    public int getAD_Org_ID() {
        return AD_Org_ID;
    }

    public String getName() {
        return name;
    }
}
