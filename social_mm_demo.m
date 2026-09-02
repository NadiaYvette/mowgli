%---------------------------------------------------------------------------%
% social_mm_demo.m — a situated secret handoff.
%---------------------------------------------------------------------------%

:- module social_mm_demo.

:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module bool.
:- import_module list.
:- import_module set.
:- import_module social_mm.
:- import_module string.

main(!IO) :-
    C0 = social_mm.empty_context,
    C1 = social_mm.add_agent(C0, "alice"),
    C2 = social_mm.add_agent(C1, "bob"),
    C3 = social_mm.add_agent(C2, "carol"),
    C4 = social_mm.add_group(C3, "couriers"),
    C5 = social_mm.add_member(C4, "alice", "couriers"),
    C6 = social_mm.add_member(C5, "bob", "couriers"),
    C7 = social_mm.add_role(C6, "alice", "sender"),
    C8 = social_mm.add_role(C7, "bob", "recipient"),
    C9 = social_mm.observe(C8,
        social_mm.point("alice", "package_7", "on_table")),
    C10 = social_mm.observe(C9,
        social_mm.speech("alice", "bob", "deliver(package_7)", urgent)),
    C11 = social_mm.observe(C10,
        social_mm.visible("package_7", "bob")),
    C12 = C11,
    C13 = social_mm.accommodate(C12, "deliver(package_7)"),
    CourierSet = set.from_list(["alice", "bob"]),
    Shared = social_mm.known_by_all(C13, CourierSet, "deliver(package_7)"),
    BobSees = social_mm.visible_to(C13, "package_7", "bob"),
    CarolSees = social_mm.visible_to(C13, "package_7", "carol"),
    Ref = social_mm.referent(C13, "alice", "on_table"),
    io.write_string("== Social Multimodal Demo ==\n", !IO),
    io.write_string("Alice points at package_7 while urgently asking Bob to deliver it.\n", !IO),
    io.format("resolved referent: %s\n", [s(Ref)], !IO),
    io.format("courier group shares delivery proposition: %s\n", [s(bool_text(Shared))], !IO),
    io.format("package visible to Bob: %s; to Carol: %s\n",
        [s(bool_text(BobSees)), s(bool_text(CarolSees))], !IO),
    io.write_string("The demo keeps speech, gesture, visibility, and accommodation distinct.\n", !IO).

:- func bool_text(bool) = string.
bool_text(yes) = "yes".
bool_text(no) = "no".

:- end_module social_mm_demo.
