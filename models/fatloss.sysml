package FatLoss {
    private import ScalarValues::*;

    part def InputForm {
        attribute age : Integer;
        attribute restingPulse : Integer;
        attribute equipment : String;
    }

    part def Calculation {
        attribute accepted : Boolean;
        attribute startRaw : Real;
        attribute targetRaw : Real;
    }

    part def ResultView {
        attribute startPulse : Integer;
        attribute targetPulse : Integer;
        attribute equipment : String;
    }

    part def FatLossApp {
        part form : InputForm;
        part calculation : Calculation;
        part result : ResultView;
    }

    requirement def <'FR-002'> ValidInput {
        subject app : FatLossApp;
        require constraint {
            not app.calculation.accepted or
            (app.form.age >= 1 and app.form.age <= 120 and
             app.form.restingPulse >= 30 and app.form.restingPulse <= 120 and
             app.form.restingPulse < 220 - app.form.age)
        }
    }

    requirement def <'FR-003'> PulseZone {
        subject app : FatLossApp;
        require constraint {
            not app.calculation.accepted or
            (app.calculation.startRaw == app.form.restingPulse +
                (220 - app.form.age - app.form.restingPulse) * 0.50 and
             app.calculation.targetRaw == app.form.restingPulse +
                (220 - app.form.age - app.form.restingPulse) * 0.70)
        }
    }

    requirement def <'FR-006'> EquipmentConsistency {
        subject app : FatLossApp;
        require constraint {
            not app.calculation.accepted or
            app.result.equipment == app.form.equipment
        }
    }

    part app : FatLossApp;
    satisfy requirement checkedInput : ValidInput by app;
    satisfy requirement pulseZone : PulseZone by app;
    satisfy requirement equipmentLabel : EquipmentConsistency by app;
}
