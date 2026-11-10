import React from "react";

export const Residents = ({ buildingId, residents, years }) => (
    years.map(year => residents[year] && (
        <div key={year} className="mt-4">
            <h5 className="mb-3">Residents in {year}</h5>
            {residents[year].map((family, index) => (
                <div key={`family-${index}`}>
                    {family.map((person, personIndex) => (
                        <React.Fragment key={`person-${buildingId}-${personIndex}`}>
                            <Resident person={person} year={year} />
                            <hr />
                        </React.Fragment>
                    ))}
                </div>
            ))}
        </div>
    ))
)

const Resident = ({ person, year }) => {
    let occupation = person.occupation;
    if (person.occupation === "None") {
        occupation = null;
    }
    if (person.relation_to_head === person.occupation) {
        occupation = null;
    }
    return (
        <div className="row">
            <div className="col-7 col-sm-6">
                <a href={`/census/${year}/${person.id}`} target="_blank">{person.name}</a>
            </div>
            <div className="col-5 col-sm-6">
                {person.relation_to_head}
            </div>
            <div className="col-6 col-sm-6">
                Age {person.age} - {person.race} - {person.sex}
            </div>
            {occupation && <div className="col-6 col-sm-6">{occupation}</div>}
        </div>
    )
}