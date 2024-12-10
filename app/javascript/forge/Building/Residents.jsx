import React from "react";
import { Row, Col } from "reactstrap";

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

const Resident = ({person, year}) => {
    let occupation = person.occupation;
    if (person.occupation === "None") {
        occupation = null;
    }
    if (person.relation_to_head === person.occupation) {
        occupation = null;
    }
    return (
        <Row>
            <Col size={7} sm={6}>
                <a href={`/census/${year}/${person.id}`} target="_blank">{person.name}</a>
            </Col>
            <Col size={5} sm={6}>
                {person.relation_to_head}
            </Col>
            <Col size={6} sm={6}>
                Age {person.age} - {person.race} - {person.sex}
            </Col>
            {occupation && <Col size={6} sm={6}>{occupation}</Col>}
        </Row>
    )
}