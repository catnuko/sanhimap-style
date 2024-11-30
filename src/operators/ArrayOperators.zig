const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std")
const Value = std.json.Value;
const string = @import("../string.zig");
const mem = @import("../mem.zig");
const VALID_ELEMENT_TYPES = [_][]const u8{
    "boolean", "number", "string"
}
fn checkElementTypes(arg: Expr, array: Value.Array) {
    if (!(arg.getType()=="StringLiteralExpr") or !mem.includes(&VALID_ELEMENT_TYPES,arg.value)) {
        @panic("expected \"boolean\", \"number\" or \"string\" instead of " ++ arg.value;);
    }
    const ty = arg.value;
    for(array.items,0..)|item,index|{
        if (typeof element !== ty) {
            @panic("expected array element at index " ++ index ++ " to have type " ++ ty);
        }
    }
}

fn checkArray(context:ExprEvaluatorContext,arg:Expr)Value{
    
}
pub const ArrayOperators = [_]OperatorDescriptor{
    .{
        .name = "array",
        .call = fn(context:ExprEvaluatorContext,call:CallExpr)Value{
            switch(call.args.len){
                0=>{
                    @panic("not enough arguments");
                },
                1=>{
                    return checkArray(context,call.args[0]);
                },
                2=>{
                    const array = checkArray(context,call.args[0]);

                },
                3=>{
                    return checkArray(context,call.args[0]);
                },
            }
        },
    },
    .{
        .name = "make-array",
        .call = fn(context:ExprEvaluatorContext,call:CallExpr)Value{
            
        },
    },
    .{
        .name = "at",
        .call = fn(context:ExprEvaluatorContext,call:CallExpr)Value{
            
        },
    },
    .{
        .name = "slice",
        .call = fn(context:ExprEvaluatorContext,call:CallExpr)Value{
            
        },
    },
};